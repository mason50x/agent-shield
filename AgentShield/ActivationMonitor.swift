import AppKit

@MainActor
final class ActivationMonitor {
    private var eventTap: ModifierEventTap?
    private var holdTask: Task<Void, Never>?
    private var heldOptionKeys: Set<UInt16> = []
    private var functionIsHeld = false
    private var gestureFired = false
    private let command: () -> ActivationCommand
    private let activate: () -> Void

    init(command: @escaping () -> ActivationCommand, activate: @escaping () -> Void) {
        self.command = command; self.activate = activate
    }

    func start() {
        stop()
        guard Self.ensureInputMonitoringAccess() else { return }
        let tap = ModifierEventTap { [weak self] keyCode, flags in
            Task { @MainActor in self?.handle(keyCode: keyCode, flags: flags) }
        }
        guard tap.start() else { return }
        eventTap = tap
    }

    static func ensureInputMonitoringAccess() -> Bool {
        CGPreflightListenEventAccess() || CGRequestListenEventAccess()
    }

    func stop() {
        eventTap?.stop(); eventTap = nil
        heldOptionKeys.removeAll(); functionIsHeld = false
        cancelHold()
    }

    private func handle(keyCode: UInt16, flags: CGEventFlags) {
        guard keyCode == 58 || keyCode == 61 || keyCode == 63 else { return }
        if keyCode == 58 || keyCode == 61 {
            if heldOptionKeys.contains(keyCode) { heldOptionKeys.remove(keyCode) }
            else { heldOptionKeys.insert(keyCode) }
            if !flags.contains(.maskAlternate) { heldOptionKeys.removeAll() }
        } else {
            functionIsHeld.toggle()
            if !flags.contains(.maskSecondaryFn) { functionIsHeld = false }
        }

        let gestureIsHeld = switch command() {
        case .bothOptions: heldOptionKeys == Set([58, 61])
        case .function: functionIsHeld
        }
        if command() == .bothOptions, gestureIsHeld, !gestureFired {
            gestureFired = true
            activate()
        } else if command() == .function, gestureIsHeld, holdTask == nil {
            holdTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(1.2))
                guard !Task.isCancelled else { return }
                self?.activate()
                self?.cancelHold()
            }
        } else if !gestureIsHeld {
            gestureFired = false
            cancelHold()
        }
    }

    private func cancelHold() { holdTask?.cancel(); holdTask = nil }
}

private final class ModifierEventTap: @unchecked Sendable {
    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private let handler: @Sendable (UInt16, CGEventFlags) -> Void

    init(handler: @escaping @Sendable (UInt16, CGEventFlags) -> Void) { self.handler = handler }

    func start() -> Bool {
        let context = Unmanaged.passUnretained(self).toOpaque()
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                guard type == .flagsChanged, let userInfo else { return Unmanaged.passUnretained(event) }
                let owner = Unmanaged<ModifierEventTap>.fromOpaque(userInfo).takeUnretainedValue()
                let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
                owner.handler(keyCode, event.flags)
                return Unmanaged.passUnretained(event)
            },
            userInfo: context
        ) else { return false }
        self.tap = tap
        source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    func stop() {
        if let source { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes) }
        if let tap { CFMachPortInvalidate(tap) }
        source = nil; tap = nil
    }
}

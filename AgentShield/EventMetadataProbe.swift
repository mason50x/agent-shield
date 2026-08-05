import AppKit

final class EventMetadataProbe: @unchecked Sendable {
    static let marker: Int64 = 0x41534849454C44
    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private let report: @Sendable (String) -> Void

    init(report: @escaping @Sendable (String) -> Void) { self.report = report }

    func start() -> Bool {
        stop()
        let mask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.leftMouseDown.rawValue) | (1 << CGEventType.mouseMoved.rawValue) | (1 << CGEventType.scrollWheel.rawValue)
        let context = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .listenOnly,
                                          eventsOfInterest: CGEventMask(mask), callback: { _, type, event, info in
            let owner = Unmanaged<EventMetadataProbe>.fromOpaque(info!).takeUnretainedValue()
            let pid = event.getIntegerValueField(.eventSourceUnixProcessID)
            let state = event.getIntegerValueField(.eventSourceStateID)
            let marker = event.getIntegerValueField(.eventSourceUserData)
            owner.report("type=\(type.rawValue) pid=\(pid) state=\(state) marker=0x\(String(marker, radix: 16))")
            return Unmanaged.passUnretained(event)
        }, userInfo: context) else { return false }
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

    func postMarkedClick(at appKitPoint: CGPoint) {
        let maxY = NSScreen.screens.map(\.frame.maxY).max() ?? 0
        let point = CGPoint(x: appKitPoint.x, y: maxY - appKitPoint.y)
        let eventSource = CGEventSource(stateID: .privateState)
        for type in [CGEventType.leftMouseDown, .leftMouseUp] {
            guard let event = CGEvent(mouseEventSource: eventSource, mouseType: type, mouseCursorPosition: point, mouseButton: .left) else { continue }
            event.setIntegerValueField(.eventSourceUserData, value: Self.marker)
            event.post(tap: .cghidEventTap)
        }
    }
}


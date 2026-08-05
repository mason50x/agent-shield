import AppKit
import Combine
import ServiceManagement

enum ActivationCommand: String, CaseIterable, Identifiable {
    case bothOptions
    case function

    var id: String { rawValue }
    var title: String {
        switch self { case .bothOptions: "Both Option Keys"; case .function: "Fn / Globe" }
    }
    var symbol: String { switch self { case .bothOptions: "⌥  +  ⌥"; case .function: "fn" } }
    var detail: String {
        switch self {
        case .bothOptions: "Press the left and right Option keys together"
        case .function: "Hold the Fn or Globe key"
        }
    }
}

@MainActor
final class AppPreferences: ObservableObject {
    private enum Key {
        static let completed = "onboarding.completed"
        static let command = "activation.command"
        static let dock = "presence.dock"
        static let menuBar = "presence.menuBar"
    }
    private let defaults = UserDefaults.standard
    var onPresenceChange: (() -> Void)?

    @Published var hasCompletedOnboarding: Bool { didSet { defaults.set(hasCompletedOnboarding, forKey: Key.completed) } }
    @Published var activationCommand: ActivationCommand { didSet { defaults.set(activationCommand.rawValue, forKey: Key.command) } }
    @Published var showInDock: Bool { didSet { defaults.set(showInDock, forKey: Key.dock); onPresenceChange?() } }
    @Published var showInMenuBar: Bool { didSet { defaults.set(showInMenuBar, forKey: Key.menuBar); onPresenceChange?() } }
    @Published private(set) var startAtLogin: Bool

    init() {
        hasCompletedOnboarding = defaults.bool(forKey: Key.completed)
        activationCommand = ActivationCommand(rawValue: defaults.string(forKey: Key.command) ?? "") ?? .bothOptions
        showInDock = defaults.object(forKey: Key.dock) as? Bool ?? false
        showInMenuBar = defaults.object(forKey: Key.menuBar) as? Bool ?? true
        startAtLogin = SMAppService.mainApp.status == .enabled
    }

    func finishOnboarding() { hasCompletedOnboarding = true }
    func resetOnboarding() { hasCompletedOnboarding = false }

    func setStartAtLogin(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
            startAtLogin = SMAppService.mainApp.status == .enabled
        } catch {
            startAtLogin = SMAppService.mainApp.status == .enabled
            NSSound.beep()
        }
    }
}

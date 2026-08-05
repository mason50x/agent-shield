import SwiftUI
import AppKit

@main
struct AgentShieldApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("Agent Shield", id: "main") {
            EmptyView()
        }
        .defaultLaunchBehavior(.suppressed)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let preferences = AppPreferences()
    lazy var model = DiagnosticModel(preferences: preferences)
    private var statusItemController: StatusItemController?
    private var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        applyPresence()
        statusItemController = StatusItemController(model: model, preferences: preferences) { [weak self] in
            self?.showMainWindow()
        }
        preferences.onPresenceChange = { [weak self] in self?.applyPresence() }
        model.startActivationMonitoring()
        DispatchQueue.main.async { [weak self] in
            if self?.preferences.hasCompletedOnboarding == false {
                self?.showMainWindow()
            }
        }
    }

    private func applyPresence() {
        NSApp.setActivationPolicy(preferences.showInDock ? .regular : .accessory)
        statusItemController?.setVisible(preferences.showInMenuBar)
    }

    private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if mainWindow == nil { createMainWindow() }
        mainWindow?.makeKeyAndOrderFront(nil)
        mainWindow?.orderFrontRegardless()
    }

    private func createMainWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 820, height: 620),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Agent Shield Settings"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.contentView = NSHostingView(rootView: RootView(model: model, preferences: preferences).preferredColorScheme(.dark))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        mainWindow = window
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }
}

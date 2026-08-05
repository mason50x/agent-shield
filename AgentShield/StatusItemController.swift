import AppKit

@MainActor
final class StatusItemController: NSObject {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private weak var model: DiagnosticModel?
    private let preferences: AppPreferences
    private let showWindow: () -> Void

    init(model: DiagnosticModel, preferences: AppPreferences, showWindow: @escaping () -> Void) {
        self.model = model; self.preferences = preferences; self.showWindow = showWindow
        super.init()
        item.button?.image = MenuBarIcon.make()
        item.menu = buildMenu()
        setVisible(preferences.showInMenuBar)
    }

    func setVisible(_ visible: Bool) { item.isVisible = visible }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        let toggle = NSMenuItem(title: "Activate Agent Mode", action: #selector(toggleShield), keyEquivalent: "")
        toggle.target = self; menu.addItem(toggle)
        menu.addItem(.separator())
        let open = NSMenuItem(title: "Settings…", action: #selector(openApp), keyEquivalent: ",")
        open.target = self; menu.addItem(open)
        let quit = NSMenuItem(title: "Quit Agent Shield", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self; menu.addItem(quit)
        menu.delegate = self
        return menu
    }

    @objc private func toggleShield() { model?.toggleOverlays() }
    @objc private func openApp() { showWindow() }
    @objc private func quitApp() { NSApp.terminate(nil) }
}

extension StatusItemController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        menu.item(at: 0)?.title = model?.overlayVisible == true ? "Leave Agent Mode" : "Activate Agent Mode"
    }
}

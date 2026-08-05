import AppKit
import Combine

@MainActor
final class DiagnosticModel: ObservableObject {
    @Published var overlayVisible = false
    @Published var interceptsPointer = true { didSet { overlays.setInterceptsPointer(interceptsPointer) } }
    @Published var isCapturing = false
    @Published var captureStatus = "Ready"
    @Published var monitoringEvents = false
    @Published var eventLog = ""
    @Published var status = "Ready for controlled feasibility tests"

    private let overlays = OverlayWindowController()
    private let captureBroker = CaptureProbe()
    private let preferences: AppPreferences
    private lazy var activationMonitor = ActivationMonitor(
        command: { [weak preferences] in preferences?.activationCommand ?? .bothOptions },
        activate: { [weak self] in self?.toggleOverlays() }
    )
    private lazy var eventProbe = EventMetadataProbe { [weak self] line in
        Task { @MainActor in
            guard let self else { return }
            let previous = self.eventLog.split(separator: "\n").prefix(30).map(String.init)
            self.eventLog = ([line] + previous).joined(separator: "\n")
        }
    }

    init(preferences: AppPreferences) {
        self.preferences = preferences
    }

    func startActivationMonitoring() { activationMonitor.start() }

    func toggleOverlays() { overlayVisible ? hideOverlays() : showOverlays() }
    func showOverlays() {
        overlays.show(interceptsPointer: interceptsPointer)
        overlayVisible = true
        status = "Agent Mode active"
    }
    func hideOverlays() {
        overlays.hide(); overlayVisible = false; status = "Overlays removed"
    }

    func capture() async {
        isCapturing = true; captureStatus = "Requesting capture…"
        defer { isCapturing = false }
        do {
            let image = try await captureBroker.captureMainDisplay(excluding: overlays.windowNumbers)
            let panel = NSSavePanel(); panel.nameFieldStringValue = "agent-shield-clean-capture.png"
            guard panel.runModal() == .OK, let url = panel.url else { captureStatus = "Save cancelled"; return }
            try image.writePNG(to: url)
            captureStatus = "Saved \(url.lastPathComponent)"
        } catch { captureStatus = "Failed: \(error.localizedDescription)" }
    }

    func toggleEventProbe() {
        if monitoringEvents { eventProbe.stop(); monitoringEvents = false }
        else { monitoringEvents = eventProbe.start(); status = monitoringEvents ? "Event metadata probe active" : "Event tap permission unavailable" }
    }
    func postMarkedClick() { eventProbe.postMarkedClick(at: NSEvent.mouseLocation) }
}

private extension NSBitmapImageRep {
    func writePNG(to url: URL) throws {
        guard let data = representation(using: .png, properties: [:]) else { throw CocoaError(.fileWriteUnknown) }
        try data.write(to: url, options: .atomic)
    }
}

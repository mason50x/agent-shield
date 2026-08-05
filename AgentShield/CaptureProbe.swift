import AppKit
import ScreenCaptureKit

struct CaptureProbe {
    func captureMainDisplay(excluding windowIDs: [CGWindowID]) async throws -> NSBitmapImageRep {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        guard let screen = NSScreen.main,
              let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
              let display = content.displays.first(where: { $0.displayID == displayID }) else {
            throw CaptureError.displayNotFound
        }
        let excluded = content.windows.filter { windowIDs.contains($0.windowID) }
        let filter = SCContentFilter(display: display, excludingWindows: excluded)
        let config = SCStreamConfiguration()
        config.width = display.width * 2
        config.height = display.height * 2
        config.showsCursor = true
        let cgImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
        return NSBitmapImageRep(cgImage: cgImage)
    }
    enum CaptureError: LocalizedError {
        case displayNotFound
        var errorDescription: String? { "The main ScreenCaptureKit display could not be resolved." }
    }
}


import SwiftUI
import AppKit

struct DiagnosticView: View {
    @ObservedObject var model: DiagnosticModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Agent Shield").font(.largeTitle.bold())
                    Text("macOS 27 feasibility spike — not an OS lock screen")
                        .foregroundStyle(.secondary)
                }
            }

            GroupBox("Overlay experiment") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Creates one unmistakable window per display at the public screen-saver level. Escape removes the overlays during this spike.")
                        .foregroundStyle(.secondary)
                    HStack {
                        Button(model.overlayVisible ? "Remove overlays" : "Show overlays") {
                            model.toggleOverlays()
                        }
                        .buttonStyle(.borderedProminent)
                        Toggle("Overlay intercepts pointer input", isOn: $model.interceptsPointer)
                    }
                }.padding(8)
            }

            GroupBox("ScreenCaptureKit") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Captures the main display using SCContentFilter(excludingWindows:) and saves a PNG chosen by you.")
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Capture excluding overlays") { Task { await model.capture() } }
                        ProgressView().opacity(model.isCapturing ? 1 : 0)
                        Text(model.captureStatus).foregroundStyle(.secondary)
                    }
                }.padding(8)
            }

            GroupBox("Input metadata probe") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button(model.monitoringEvents ? "Stop event probe" : "Start event probe") {
                            model.toggleEventProbe()
                        }
                        Button("Post marked synthetic click") { model.postMarkedClick() }
                    }
                    Text("The listen-only event tap records source PID, source-state ID, and user-data marker. It does not suppress input.")
                        .foregroundStyle(.secondary)
                    ScrollView {
                        Text(model.eventLog.isEmpty ? "No events recorded." : model.eventLog)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.frame(height: 150)
                }.padding(8)
            }

            Spacer()
            HStack {
                Circle().fill(model.overlayVisible ? .orange : .green).frame(width: 9, height: 9)
                Text(model.status).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("Diagnostic only • no input suppression • no authentication")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

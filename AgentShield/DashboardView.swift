import SwiftUI

struct SettingsView: View {
    @ObservedObject var preferences: AppPreferences

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Settings").font(.system(size: 36, weight: .bold))
                Text("Choose how Agent Shield activates and where it appears.").foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                SettingsCommandRow(title: "Both Option keys", detail: "Press left and right Option together", command: .bothOptions, selection: $preferences.activationCommand)
                SettingsCommandRow(title: "Fn / Globe key", detail: "Hold the Fn or Globe key", command: .function, selection: $preferences.activationCommand)
            }

            VStack(spacing: 12) {
                ToggleRow(icon: "menubar.rectangle", title: "Show in menu bar", isOn: $preferences.showInMenuBar)
                ToggleRow(icon: "dock.rectangle", title: "Show in Dock", isOn: $preferences.showInDock)
                ToggleRow(
                    icon: "power",
                    title: "Start at login",
                    isOn: Binding(
                        get: { preferences.startAtLogin },
                        set: { preferences.setStartAtLogin($0) }
                    )
                )
            }

            Spacer()
            Button("Run onboarding again") { preferences.resetOnboarding() }
                .buttonStyle(.glass).buttonBorderShape(.capsule).controlSize(.large)
        }
        .padding(42)
    }
}

private struct SettingsCommandRow: View {
    let title: String
    let detail: String
    let command: ActivationCommand
    @Binding var selection: ActivationCommand

    var body: some View {
        Button { selection = command } label: {
            HStack(spacing: 16) {
                Image(systemName: "keyboard").foregroundStyle(.cyan).frame(width: 28)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline)
                    Text(detail).font(.callout).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: selection == command ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selection == command ? .cyan : .secondary)
            }
            .padding(16).background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 15))
        }.buttonStyle(.plain)
    }
}

private struct ToggleRow: View {
    let icon: String; let title: String; @Binding var isOn: Bool
    var body: some View {
        HStack { Image(systemName: icon).foregroundStyle(.cyan).frame(width: 28); Text(title).font(.headline); Spacer(); Toggle("", isOn: $isOn).labelsHidden() }
            .padding(16).background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 15))
    }
}

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var preferences: AppPreferences
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if page == 0 { IntroPage() }
                else if page == 1 { CommandPage(selection: $preferences.activationCommand) }
                else { PresencePage(showInDock: $preferences.showInDock, showInMenuBar: $preferences.showInMenuBar) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(page)
            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            HStack {
                Button("Back") { withAnimation { page -= 1 } }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .font(.headline)
                    .opacity(page == 0 ? 0 : 1).disabled(page == 0)
                Spacer()
                Button(page == 2 ? "Finish setup" : "Continue") {
                    if page == 1 { _ = ActivationMonitor.ensureInputMonitoringAccess() }
                    if page == 2 { preferences.finishOnboarding() } else { withAnimation(.snappy) { page += 1 } }
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .tint(.cyan)
                .foregroundStyle(.white)
                .controlSize(.large)
                .font(.headline)
                .padding(.horizontal, 8)
            }.padding(28)
        }
    }
}

private struct IntroPage: View {
    var body: some View {
        VStack(spacing: 22) {
            Text("Privacy for your screen.\nFreedom for your agents.")
                .font(.system(size: 42, weight: .bold)).multilineTextAlignment(.center)
            Text("Agent Mode covers every physical display while your Mac session, apps, servers, and authorized agents keep working underneath.")
                .font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center).frame(maxWidth: 610)
        }.padding(50)
    }
}

private struct CommandPage: View {
    @Binding var selection: ActivationCommand
    var body: some View {
        VStack(spacing: 26) {
            VStack(spacing: 8) {
                Text("Choose your activation command").font(.system(size: 34, weight: .bold))
                Text("Use a deliberate key gesture whenever you want to enter Agent Mode.").foregroundStyle(.secondary)
            }
            GlassEffectContainer(spacing: 20) {
                HStack(spacing: 20) {
                    ForEach(ActivationCommand.allCases) { command in
                        Button { selection = command } label: {
                        VStack(spacing: 16) {
                            Text(command.symbol).font(.system(size: 30, weight: .semibold))
                                .frame(width: 72, height: 58).background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                            Text(command.title).font(.headline)
                            Text(command.detail).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center).frame(height: 34)
                            Image(systemName: selection == command ? "checkmark.circle.fill" : "circle").foregroundStyle(selection == command ? .cyan : .secondary)
                        }
                        .padding(18).frame(width: 240, height: 220)
                        .contentShape(.rect(cornerRadius: 22))
                        .glassEffect(
                            .regular.tint(selection == command ? .cyan.opacity(0.28) : .clear).interactive(),
                            in: .rect(cornerRadius: 22)
                        )
                    }.buttonStyle(.plain)
                    }
                }
            }
            VStack(spacing: 5) {
                Text("You can change this later in Agent Shield settings.")
                Text("macOS will request Input Monitoring when you continue. Relaunch Agent Shield after granting access.")
            }.font(.caption).foregroundStyle(.tertiary).multilineTextAlignment(.center)
        }.padding(44)
    }
}

private struct PresencePage: View {
    @Binding var showInDock: Bool
    @Binding var showInMenuBar: Bool
    var body: some View {
        VStack(spacing: 26) {
            VStack(spacing: 8) {
                Text("Where should Agent Shield live?").font(.system(size: 34, weight: .bold))
                Text("Keep it close without adding clutter.").foregroundStyle(.secondary)
            }
            VStack(spacing: 12) {
                PresenceRow(icon: "menubar.rectangle", title: "Show in menu bar", detail: "Quick access to Agent Mode and settings", isOn: $showInMenuBar, recommended: true)
                PresenceRow(icon: "dock.rectangle", title: "Show in Dock", detail: "Keep Agent Shield visible beside your other apps", isOn: $showInDock, recommended: false)
            }.frame(maxWidth: 580)
            Text("Default: menu bar on, Dock hidden").font(.caption).foregroundStyle(.tertiary)
        }.padding(50)
    }
}

private struct PresenceRow: View {
    let icon: String; let title: String; let detail: String
    @Binding var isOn: Bool
    let recommended: Bool
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.title2).foregroundStyle(.cyan).frame(width: 38)
            VStack(alignment: .leading, spacing: 4) {
                HStack { Text(title).font(.headline); if recommended { Text("RECOMMENDED").font(.system(size: 9, weight: .bold)).foregroundStyle(.cyan) } }
                Text(detail).font(.callout).foregroundStyle(.secondary)
            }
            Spacer(); Toggle("", isOn: $isOn).labelsHidden().toggleStyle(.switch)
        }.padding(18).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18))
    }
}

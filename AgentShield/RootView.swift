import SwiftUI

struct RootView: View {
    @ObservedObject var model: DiagnosticModel
    @ObservedObject var preferences: AppPreferences

    var body: some View {
        ZStack {
            AppBackground()
            if preferences.hasCompletedOnboarding {
                SettingsView(preferences: preferences)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView(preferences: preferences)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.snappy(duration: 0.45), value: preferences.hasCompletedOnboarding)
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.045, blue: 0.07)
            RadialGradient(colors: [Color.cyan.opacity(0.16), .clear], center: .topLeading, startRadius: 0, endRadius: 600)
            RadialGradient(colors: [Color.indigo.opacity(0.18), .clear], center: .bottomTrailing, startRadius: 30, endRadius: 520)
        }.ignoresSafeArea()
    }
}

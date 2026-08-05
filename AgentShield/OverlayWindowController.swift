import AppKit
import SwiftUI

@MainActor
final class OverlayWindowController {
    private(set) var windows: [NSWindow] = []
    var windowNumbers: [CGWindowID] { windows.map { CGWindowID($0.windowNumber) } }
    private var observers: [NSObjectProtocol] = []

    func show(interceptsPointer: Bool) {
        hide()
        rebuild(interceptsPointer: interceptsPointer)
        let center = NotificationCenter.default
        for name in [NSApplication.didChangeScreenParametersNotification, NSWorkspace.activeSpaceDidChangeNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.rebuild(interceptsPointer: interceptsPointer) }
            })
        }
    }

    func hide() {
        windows.forEach { $0.orderOut(nil) }; windows.removeAll()
        observers.forEach(NotificationCenter.default.removeObserver); observers.removeAll()
    }

    func setInterceptsPointer(_ value: Bool) { windows.forEach { $0.ignoresMouseEvents = !value } }

    private func rebuild(interceptsPointer: Bool) {
        windows.forEach { $0.orderOut(nil) }
        windows = NSScreen.screens.enumerated().map { index, screen in
            let window = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false, screen: screen)
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            window.isOpaque = true; window.backgroundColor = .black; window.hasShadow = false
            window.ignoresMouseEvents = !interceptsPointer
            window.contentView = NSHostingView(rootView: AgentModeOverlay(topInset: screen.safeAreaInsets.top))
            window.setFrame(screen.frame, display: true); window.orderFrontRegardless()
            return window
        }
    }
}

private struct AgentModeOverlay: View {
    let topInset: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()

            GeometryReader { proxy in
                VStack(spacing: 0) {
                    PixelClockView()
                        .padding(.top, max(72, proxy.size.height * 0.09))
                    Spacer()
                    Text("Background work is underway.")
                        .font(.system(size: 28, weight: .medium))
                        .multilineTextAlignment(.center)
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            WorkingBorder(reduceMotion: reduceMotion, notchDepth: topInset)
        }
        .ignoresSafeArea()
    }
}

private struct WorkingBorder: View {
    let reduceMotion: Bool
    let notchDepth: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1 / 30)) { context in
            let time = reduceMotion ? 0.0 : context.date.timeIntervalSinceReferenceDate
            let primaryPhase = time.truncatingRemainder(dividingBy: 7.5) / 7.5
            let secondaryPhase = time.truncatingRemainder(dividingBy: 11) / 11
            ZStack {
                NotchedScreenContour(notchDepth: notchDepth)
                    .stroke(flowGradient(phase: primaryPhase), lineWidth: 30)
                    .blur(radius: 25)
                    .opacity(colorScheme == .dark ? 0.48 : 0.58)
                NotchedScreenContour(notchDepth: notchDepth)
                    .stroke(flowGradient(phase: -secondaryPhase + 0.18), lineWidth: 14)
                    .blur(radius: 12)
                    .opacity(colorScheme == .dark ? 0.58 : 0.72)
                NotchedScreenContour(notchDepth: notchDepth)
                    .stroke(flowGradient(phase: primaryPhase * 0.62 + 0.4), lineWidth: 5)
                    .blur(radius: 7)
                    .opacity(colorScheme == .dark ? 0.42 : 0.55)
            }
            .padding(2)
        }
        .allowsHitTesting(false)
    }

    private func flowGradient(phase: Double) -> AngularGradient {
        let colors: [Color] = colorScheme == .dark
            ? [.white.opacity(0.92), .gray.opacity(0.20), .white.opacity(0.40), .gray.opacity(0.12), .white.opacity(0.78), .gray.opacity(0.28), .white.opacity(0.92)]
            : [Color(red: 0.05, green: 0.32, blue: 0.95), Color(red: 0.35, green: 0.68, blue: 1), Color(red: 0.08, green: 0.43, blue: 1), Color(red: 0.62, green: 0.82, blue: 1), Color(red: 0.03, green: 0.24, blue: 0.82), Color(red: 0.28, green: 0.61, blue: 1), Color(red: 0.05, green: 0.32, blue: 0.95)]
        return AngularGradient(colors: colors, center: .center, angle: .degrees(phase * 360))
    }
}

private struct NotchedScreenContour: Shape {
    let notchDepth: CGFloat

    func path(in rect: CGRect) -> Path {
        let inset: CGFloat = 5
        let r = rect.insetBy(dx: inset, dy: inset)
        let corner: CGFloat = 18
        let depth = max(0, notchDepth - inset)
        let halfNotch: CGFloat = depth > 0 ? 92 : 0
        let center = r.midX
        var path = Path()
        path.move(to: CGPoint(x: r.minX + corner, y: r.minY))
        if depth > 0 {
            path.addLine(to: CGPoint(x: center - halfNotch - 14, y: r.minY))
            path.addCurve(
                to: CGPoint(x: center - halfNotch, y: r.minY + 14),
                control1: CGPoint(x: center - halfNotch - 5, y: r.minY),
                control2: CGPoint(x: center - halfNotch, y: r.minY + 5)
            )
            path.addLine(to: CGPoint(x: center - halfNotch, y: r.minY + depth - 12))
            path.addCurve(
                to: CGPoint(x: center - halfNotch + 12, y: r.minY + depth),
                control1: CGPoint(x: center - halfNotch, y: r.minY + depth - 5),
                control2: CGPoint(x: center - halfNotch + 5, y: r.minY + depth)
            )
            path.addLine(to: CGPoint(x: center + halfNotch - 12, y: r.minY + depth))
            path.addCurve(
                to: CGPoint(x: center + halfNotch, y: r.minY + depth - 12),
                control1: CGPoint(x: center + halfNotch - 5, y: r.minY + depth),
                control2: CGPoint(x: center + halfNotch, y: r.minY + depth - 5)
            )
            path.addLine(to: CGPoint(x: center + halfNotch, y: r.minY + 14))
            path.addCurve(
                to: CGPoint(x: center + halfNotch + 14, y: r.minY),
                control1: CGPoint(x: center + halfNotch, y: r.minY + 5),
                control2: CGPoint(x: center + halfNotch + 5, y: r.minY)
            )
        }
        path.addLine(to: CGPoint(x: r.maxX - corner, y: r.minY))
        path.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + corner), control: CGPoint(x: r.maxX, y: r.minY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.maxY - corner))
        path.addQuadCurve(to: CGPoint(x: r.maxX - corner, y: r.maxY), control: CGPoint(x: r.maxX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.minX + corner, y: r.maxY))
        path.addQuadCurve(to: CGPoint(x: r.minX, y: r.maxY - corner), control: CGPoint(x: r.minX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.minX, y: r.minY + corner))
        path.addQuadCurve(to: CGPoint(x: r.minX + corner, y: r.minY), control: CGPoint(x: r.minX, y: r.minY))
        path.closeSubpath()
        return path
    }
}

private struct PixelClockView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { context in
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: context.date)
            let hour = ((components.hour ?? 0) + 11) % 12 + 1
            let minute = components.minute ?? 0
            let digits = [hour / 10, hour % 10, minute / 10, minute % 10]
            HStack(spacing: 13) {
                if digits[0] > 0 { PixelDigit(value: digits[0]) }
                PixelDigit(value: digits[1])
                PixelColon(isOn: (components.second ?? 0).isMultiple(of: 2))
                    .padding(.horizontal, 2)
                PixelDigit(value: digits[2])
                PixelDigit(value: digits[3])
            }
            .foregroundStyle(.primary)
            .animation(.easeInOut(duration: 0.25), value: (components.second ?? 0).isMultiple(of: 2))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(context.date, style: .time))
        }
    }
}

private struct PixelColon: View {
    let isOn: Bool
    var body: some View {
        VStack(spacing: 18) {
            Rectangle().frame(width: 14, height: 14)
            Rectangle().frame(width: 14, height: 14)
        }.opacity(isOn ? 1 : 0.2)
    }
}

private struct PixelDigit: View {
    let value: Int
    private static let maps: [[String]] = [
        ["111", "101", "101", "101", "101", "101", "111"],
        ["010", "110", "010", "010", "010", "010", "111"],
        ["111", "001", "001", "111", "100", "100", "111"],
        ["111", "001", "001", "111", "001", "001", "111"],
        ["101", "101", "101", "111", "001", "001", "001"],
        ["111", "100", "100", "111", "001", "001", "111"],
        ["111", "100", "100", "111", "101", "101", "111"],
        ["111", "001", "001", "010", "010", "010", "010"],
        ["111", "101", "101", "111", "101", "101", "111"],
        ["111", "101", "101", "111", "001", "001", "111"]
    ]

    var body: some View {
        Grid(horizontalSpacing: 5, verticalSpacing: 5) {
            ForEach(Array(Self.maps[value].enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, pixel in
                        Rectangle()
                            .fill(pixel == "1" ? Color.primary : Color.clear)
                            .frame(width: 17, height: 17)
                    }
                }
            }
        }
    }
}

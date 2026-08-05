import AppKit

enum MenuBarIcon {
    static func make() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.labelColor.setFill()
            let dot: CGFloat = 2.15
            let step: CGFloat = 3.05
            let origin = CGPoint(x: 1.35, y: 0.1)
            let points: [(Int, Int)] = [
                (1, 5), (2, 5), (3, 5),
                (0, 4), (1, 4), (3, 4), (4, 4),
                (0, 3), (4, 3),
                (0, 2), (1, 2), (2, 2), (3, 2), (4, 2),
                (0, 1), (1, 1), (2, 1), (3, 1), (4, 1),
                (0, 0), (1, 0), (2, 0), (3, 0), (4, 0)
            ]
            for (column, row) in points {
                let rect = NSRect(
                    x: origin.x + CGFloat(column) * step,
                    y: origin.y + CGFloat(row) * step,
                    width: dot,
                    height: dot
                )
                NSBezierPath(ovalIn: rect).fill()
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Agent Shield"
        return image
    }
}

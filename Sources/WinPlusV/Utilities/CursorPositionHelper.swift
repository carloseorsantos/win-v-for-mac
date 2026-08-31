import Foundation
import AppKit

public enum CursorPositionHelper {
    /// Computes the best origin point (Cocoa coordinates, bottom-left origin) for a window
    /// of the given size so that it appears adjacent to the current mouse cursor
    /// without overflowing outside the active screen's visible area.
    public static func originForWindow(size: CGSize) -> CGPoint {
        let mouseLocation = NSEvent.mouseLocation

        // Find the screen containing the mouse cursor, or fallback to main screen
        let activeScreen = NSScreen.screens.first { screen in
            NSMouseInRect(mouseLocation, screen.frame, false)
        } ?? NSScreen.main ?? NSScreen.screens.first

        guard let screen = activeScreen else {
            return CGPoint(x: mouseLocation.x, y: mouseLocation.y - size.height)
        }

        let visibleFrame = screen.visibleFrame
        let offset: CGFloat = 12.0

        // Default: Open to the right and below the cursor
        var x = mouseLocation.x + offset
        // In macOS coordinates, lower Y is down, higher Y is up.
        // So below the cursor means: top = mouseLocation.y - offset, origin.y = top - size.height
        var y = mouseLocation.y - offset - size.height

        // If overflowing right edge, position to the left of cursor
        if x + size.width > visibleFrame.maxX {
            x = mouseLocation.x - size.width - offset
        }

        // If overflowing left edge, clamp to left margin
        if x < visibleFrame.minX {
            x = visibleFrame.minX + offset
        }

        // If overflowing bottom edge, position above cursor
        if y < visibleFrame.minY {
            y = mouseLocation.y + offset
        }

        // If overflowing top edge, clamp to top margin
        if y + size.height > visibleFrame.maxY {
            y = visibleFrame.maxY - size.height - offset
        }

        return CGPoint(x: x, y: y)
    }
}

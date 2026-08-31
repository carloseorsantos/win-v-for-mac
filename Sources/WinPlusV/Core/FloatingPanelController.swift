import Foundation
import AppKit
import SwiftUI

public final class FloatingPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        self.level = .popUpMenu
        self.isFloatingPanel = true
        self.hidesOnDeactivate = false
        self.isMovableByWindowBackground = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isOpaque = false
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.animationBehavior = .utilityWindow
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        self.becomesKeyOnlyIfNeeded = true
    }

    public override var canBecomeKey: Bool {
        return false
    }

    public override var canBecomeMain: Bool {
        return false
    }

    public override func cancelOperation(_ sender: Any?) {
        FloatingPanelController.shared.hide()
    }
}

@MainActor
public final class FloatingPanelController: ObservableObject {
    public static let shared = FloatingPanelController()

    private var panel: FloatingPanel?
    private var outsideClickMonitor: Any?
    private var keyMonitor: Any?
    public let defaultSize = CGSize(width: 380, height: 480)

    @Published public private(set) var isVisible: Bool = false
    public private(set) var previousApp: NSRunningApplication?

    private init() {}

    public func setPreviousApp(_ app: NSRunningApplication?) {
        if let app = app, app.bundleIdentifier != Bundle.main.bundleIdentifier {
            self.previousApp = app
        }
    }

    public func setup(contentView: AnyView) {
        let hostingView = NSHostingView(rootView: contentView)
        let frame = NSRect(origin: .zero, size: defaultSize)

        let panel = FloatingPanel(contentRect: frame)
        panel.contentView = hostingView
        self.panel = panel
    }

    public func toggleNearCursor() {
        if isVisible {
            hide()
        } else {
            if let front = NSWorkspace.shared.frontmostApplication,
               front.bundleIdentifier != Bundle.main.bundleIdentifier {
                self.previousApp = front
            }
            showNearCursor()
        }
    }

    public func showNearCursor() {
        guard let panel = self.panel else { return }

        let origin = CursorPositionHelper.originForWindow(size: defaultSize)
        panel.setFrameOrigin(origin)
        
        // Show panel without activating our app or stealing focus from the text field
        panel.orderFrontRegardless()

        self.isVisible = true
        startMonitors()
    }

    public func hide() {
        guard let panel = self.panel else { return }
        panel.orderOut(nil)
        self.isVisible = false
        stopMonitors()
    }

    private func startMonitors() {
        stopMonitors()

        // Monitor mouse clicks outside the panel to dismiss
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor [weak self] in
                guard let self = self, let panel = self.panel else { return }
                let clickLocation = NSEvent.mouseLocation
                if !NSMouseInRect(clickLocation, panel.frame, false) {
                    self.hide()
                }
            }
        }

        // Monitor Escape key globally while panel is visible
        keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor [weak self] in
                if event.keyCode == 53 { // 53 is kVK_Escape
                    self?.hide()
                }
            }
        }
    }

    private func stopMonitors() {
        if let monitor = outsideClickMonitor {
            NSEvent.removeMonitor(monitor)
            outsideClickMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
}

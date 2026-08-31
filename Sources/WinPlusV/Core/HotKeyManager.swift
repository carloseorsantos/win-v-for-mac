import Foundation
import Carbon
import AppKit

private var hotKeyHandlerInstalled = false
private var globalHotKeyCallback: (() -> Void)?

@MainActor
public final class HotKeyManager {
    public static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x57504C56), id: 1) // 'WPLV', 1

    private init() {}

    /// Registers the global shortcut (default: Option + V)
    public func registerDefaultHotKey(onTrigger: @escaping () -> Void) {
        globalHotKeyCallback = onTrigger

        if !hotKeyHandlerInstalled {
            var eventType = EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            )

            InstallEventHandler(
                GetEventDispatcherTarget(),
                { (_, eventRef, _) -> OSStatus in
                    var hkID = EventHotKeyID()
                    GetEventParameter(
                        eventRef,
                        EventParamName(kEventParamDirectObject),
                        EventParamType(typeEventHotKeyID),
                        nil,
                        MemoryLayout<EventHotKeyID>.size,
                        nil,
                        &hkID
                    )

                    if hkID.signature == OSType(0x57504C56) && hkID.id == 1 {
                        let activeApp = NSWorkspace.shared.frontmostApplication
                        DispatchQueue.main.async {
                            FloatingPanelController.shared.setPreviousApp(activeApp)
                            globalHotKeyCallback?()
                        }
                        return noErr
                    }
                    return OSStatus(eventNotHandledErr)
                },
                1,
                &eventType,
                nil,
                nil
            )
            hotKeyHandlerInstalled = true
        }

        unregisterHotKey()

        // Carbon Keycode for 'V' is 0x09 (kVK_ANSI_V = 9)
        let vKeyCode: UInt32 = 0x09
        // Carbon modifier for Option (altKey) is UInt32(optionKey) = 0x0800
        let modifiers: UInt32 = UInt32(optionKey)

        let status = RegisterEventHotKey(
            vKeyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            print("[WinPlusV] Falha ao registrar atalho Carbon HotKey. Código: \(status)")
        }
    }

    public func unregisterHotKey() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }
}

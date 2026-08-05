# Agent Shield feasibility — macOS 27

Status: **spike implemented; initial Codex/Chrome path verified**. This document distinguishes observed evidence from behavior that still requires hands-on testing and permission prompts.

## Installed Codex control stack

Process inspection on 2026-08-04 shows that the Codex desktop app launches a dedicated local component:

- `~/.codex/computer-use/Codex Computer Use.app/Contents/MacOS/SkyComputerUseService`
- `SkyComputerUseClient event-stream mcp`
- the Codex app itself is Chromium-based and launches a separate `codex app-server`

This confirms a local external computer-control service and MCP client path. Process names alone do **not** prove which Apple capture or input APIs the private implementation calls. No claim is made yet that it uses ScreenCaptureKit, CGWindowList, AXUIElement, or CGEvent.

## Spike implementation

The native diagnostic app provides:

- one opaque, unmistakable borderless AppKit window per `NSScreen`;
- `.screenSaver` level and `canJoinAllSpaces`, `fullScreenAuxiliary`, `stationary`, and `ignoresCycle` behaviors;
- display/Space-change rebuilding;
- pointer interception/pass-through toggle;
- ScreenCaptureKit still capture using `SCContentFilter(display:excludingWindows:)` and `SCScreenshotManager`;
- listen-only CGEvent metadata logging of source PID, state ID, and user-data;
- a deliberately marked synthetic click for comparison;
- Escape recovery. The spike performs no input suppression.

## Required interactive results

Record each item as pass/fail with OS build, Codex build, permissions, display topology, and evidence image/log.

| Test | Current result | Evidence needed |
|---|---|---|
| Overlay appears in Codex computer-control screenshot | **Pass: excluded for app-targeted Chrome capture** | With the overlay physically visible, `sky.get_app_state` returned a clean Chrome screenshot. An ordinary `screencapture` image taken at the same time showed the overlay. |
| Codex coordinate click hits overlay vs underlying app | **Pass: reaches Chrome underneath** | With pointer interception enabled, a coordinate click at `(700, 650)` dismissed Chrome's open Google Apps menu. |
| Physical HID vs broker CGEvent metadata is distinguishable | Untested | Event-probe lines for each source |
| Direct AXUIElement action works while overlay is frontmost | **Pass for Chrome** | An element-index click on Chrome's Google Apps button opened the menu while the shield remained physically visible. |
| SCK capture excludes all spike overlays | Implemented, unverified | Saved PNG showing underlying desktop |
| Multiple monitors and mixed scale factors | Untested | Capture and coverage per display |
| Spaces and full-screen applications | Untested | Per-Space results |
| Stage Manager | Untested | On/off results |
| Display disconnect/reconnect, rotation, resolution changes | Untested | Window frames before/after |

## Go/no-go gates for the product build

1. **Capture integration:** the installed Codex Computer Use service's app-targeted Chrome screenshot sees through the spike overlay, while macOS `screencapture` sees the shield. This is strong evidence that the existing targeted control path can satisfy Chrome operation without a replacement capture bridge. Other applications and whole-desktop capture still need verification.
2. **Input provenance:** source PID/state/marker must be measured on macOS 27. A user-data marker is useful only for events created by the authenticated broker; it does not make arbitrary external synthetic input trustworthy.
3. **Fail-safe behavior:** an event-tap timeout, crash, permission revocation, display reconfiguration, or app termination must never leave a deceptive partially shielded state.
4. **Public API boundary:** `NSWindow.sharingType` is not used as a security or capture-exclusion mechanism.
5. **Terminology:** the product is a privacy shield / Agent Mode, not OS-level lock-screen security.

The complete product should not proceed past these gates until the test table is filled with current macOS 27 evidence. The supplied brief also ends mid-sentence after “Never collect,” so its remaining authentication/recovery/packaging requirements must be recovered before final implementation.

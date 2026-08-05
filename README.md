# Agent Shield

Native macOS 27 privacy-shield application that keeps the logged-in session and development processes running. This is explicitly **not** an OS lock screen.

## Run

1. Generate the Xcode project with `xcodegen generate`.
2. Open `AgentShield.xcodeproj` and run the `AgentShield` scheme.
3. Complete the three-step onboarding to choose an activation key and whether Agent Shield appears in the menu bar or Dock.
4. Grant Screen Recording and Input Monitoring when macOS requests them, then relaunch if requested.
5. Follow the controlled test matrix in `FEASIBILITY.md` for diagnostic behavior.

The current build intentionally does not suppress physical input or authenticate an exit. Those features must not be enabled until the remaining feasibility gates have been measured.

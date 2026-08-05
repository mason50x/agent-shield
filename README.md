# Agent Shield

Native macOS 27 privacy-shield application that keeps the logged-in session and development processes running. This is explicitly **not** an OS lock screen.

## Requirements

- macOS 27 or later
- Xcode 27 or later
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) only if you want to regenerate the included Xcode project (`brew install xcodegen`)

## Download the source

Clone the repository:

```sh
git clone https://github.com/mason50x/agent-shield.git
cd agent-shield
```

Alternatively, choose **Code → Download ZIP** on GitHub, extract the archive, and open the extracted folder in Terminal.

## Run from Xcode

1. Open `AgentShield.xcodeproj` in Xcode. The project is included, so running XcodeGen first is optional.
2. Select the `AgentShield` scheme and the **My Mac** destination.
3. Press **Run** (⌘R).
4. Complete the three-step onboarding to choose an activation key and whether Agent Shield appears in the menu bar or Dock.
5. When prompted, grant Agent Shield **Screen & System Audio Recording** and **Input Monitoring** in **System Settings → Privacy & Security**, then quit and reopen the app.

To regenerate the project after changing `project.yml`, run:

```sh
xcodegen generate
```

## Build and install in Applications

Build a local release from Terminal:

```sh
xcodebuild \
  -project AgentShield.xcodeproj \
  -scheme AgentShield \
  -configuration Release \
  -derivedDataPath .derived \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Then install it for the current Mac:

```sh
ditto ".derived/Build/Products/Release/Agent Shield.app" "/Applications/Agent Shield.app"
open "/Applications/Agent Shield.app"
```

If `/Applications` is not writable by your account, prefix the `ditto` command with `sudo`. After the app opens, complete onboarding and grant the requested privacy permissions. To update the installation later, quit Agent Shield, pull the latest source, rebuild, and run the same `ditto` command again.

Follow the controlled test matrix in `FEASIBILITY.md` when evaluating diagnostic behavior.

The current build intentionally does not suppress physical input or authenticate an exit. Those features must not be enabled until the remaining feasibility gates have been measured.

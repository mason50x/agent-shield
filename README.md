# Agent Shield

> [!WARNING]
> **Work in progress:** Agent Shield is an early feasibility build. Behavior, setup, and security properties may change, and it should not be treated as an OS lock screen.

[![Build](https://github.com/mason50x/agent-shield/actions/workflows/build.yml/badge.svg)](https://github.com/mason50x/agent-shield/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Native macOS 26+ privacy-shield application that keeps the logged-in session and development processes running. This is explicitly **not** an OS lock screen.

## Requirements

- macOS 26 or later
- Xcode 26 or later (installed, and terms read)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) only if you want to regenerate the included Xcode project (`brew install xcodegen`)

## Download the source

Clone the repository:

```sh
git clone https://github.com/mason50x/agent-shield.git
cd agent-shield
```

Alternatively (hell), choose **Code → Download ZIP** on GitHub, extract the archive, and open the extracted folder in Terminal.

## Build, install, and open

After entering the `agent-shield` folder, copy and paste this single command:

```sh
xcodebuild -project AgentShield.xcodeproj -scheme AgentShield -configuration Release -derivedDataPath .derived CODE_SIGNING_ALLOWED=NO build && sudo ditto ".derived/Build/Products/Release/Agent Shield.app" "/Applications/Agent Shield.app" && open "/Applications/Agent Shield.app"
```

Enter your Mac password when `sudo` asks for it. The command builds a Release version, installs it in `/Applications`, and opens it. Complete onboarding, then grant **Screen & System Audio Recording** and **Input Monitoring** in **System Settings → Privacy & Security**. Quit and reopen Agent Shield after granting access. (The app should prompt you for this on its own.)

To update later, quit Agent Shield, run `git pull` inside the source folder, and run the same one-line command again.

Developers only need XcodeGen when regenerating `AgentShield.xcodeproj` after editing `project.yml`:

```sh
xcodegen generate
```

Follow the controlled test matrix in `FEASIBILITY.md` when evaluating diagnostic behavior.

The current build intentionally does not suppress physical input or authenticate an exit. Those features must not be enabled until the remaining feasibility gates have been measured.

## Contributing

Bug reports, feature ideas, and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md) before contributing. Report vulnerabilities privately according to [SECURITY.md](SECURITY.md).

## License

Agent Shield is available under the [MIT License](LICENSE).

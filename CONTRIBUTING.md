# Contributing to Agent Shield

Thanks for helping improve Agent Shield.

## Before You Start

- Search existing issues before opening a new one.
- Use an issue to discuss significant behavior or architecture changes first.
- Keep pull requests focused on one change.
- Never include credentials, personal data, signing identities, or generated build products.

## Development Setup

Requirements are macOS 26 or later and Xcode 26 or later. Clone the repository, then verify a Release build:

```sh
git clone https://github.com/mason50x/agent-shield.git
cd agent-shield
xcodebuild -project AgentShield.xcodeproj -scheme AgentShield -configuration Release -derivedDataPath .derived CODE_SIGNING_ALLOWED=NO build
```

The checked-in Xcode project is generated from `project.yml`. If you change the project definition, install XcodeGen, run `xcodegen generate`, and include the regenerated project file in the same pull request.

## Pull Requests

1. Create a descriptive branch from `main`.
2. Make the smallest complete change.
3. Build the project and test affected behavior on a real Mac.
4. Update documentation when behavior or setup changes.
5. Explain the change, motivation, validation, and any remaining limitations in the pull request.

By contributing, you agree that your contributions are licensed under the MIT License.

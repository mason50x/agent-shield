# Security Policy

## Supported Versions

Security fixes are provided for the latest version on the `main` branch.

## Reporting a Vulnerability

Please do not report security vulnerabilities through public GitHub issues.
Use [GitHub's private vulnerability reporting](https://github.com/mason50x/agent-shield/security/advisories/new) instead.

Include a clear description, reproduction steps, affected macOS version, and
the potential impact. You should receive an acknowledgement within 7 days.
Please allow time for investigation and a fix before public disclosure.

## Security Scope

Agent Shield is a local macOS privacy overlay. Security-sensitive areas include
activation and dismissal behavior, input monitoring, screen capture and window
exclusion, privacy-permission handling, and persistence of local preferences.

Agent Shield must not claim to provide OS-level session locking. The current
build does not suppress physical input or authenticate dismissal; these are
documented product limitations, not security controls.

Reports are evaluated based on reproducibility, realistic local reachability,
and impact to user privacy, permissions, or the integrity of Agent Shield's
documented behavior.

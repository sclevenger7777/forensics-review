# Security Policy

## Supported Versions

This repository is supported on a best-effort basis for the current code and documentation on the default branch. Historical tags and “evidence freeze” artifacts are not patched.

| Version / Branch | Supported | Notes |
| --- | --- | --- |
| `main` (latest commit) | Yes | Fixes and hardening are applied here. |
| Latest tagged release | Limited | Guidance/workarounds may be provided; tags may not be republished. |
| Older tags / commits | No | Not actively supported. |
| Primary evidence artifacts (PCAP/PCAPNG, archives, hash manifests) | No | Evidence is immutable; integrity is validated via published hashes. |

## Reporting a Vulnerability

### Private reporting (preferred)
Use GitHub Security Advisories (Private Vulnerability Reporting) when enabled for this repository. Open a new advisory and include the information listed below.

### Public reporting (fallback)
If private reporting is not available, open a public Issue with minimal detail. Prefix the title with `[SECURITY]`. Do not include sensitive data or actionable exploit instructions. Additional details may be requested via a private channel.

### Include in your report
- Description and impact
- Affected file(s) / script(s) / workflow(s)
- Steps to reproduce (safe, non-destructive)
- Proof-of-concept (optional; non-actionable)
- Environment details (OS, shell, tool versions)
- Suggested fix (optional)

### Do not post publicly
- Credentials, tokens, API keys
- Personal data / identifiers
- Unpublished private captures, logs, or artifacts outside the published evidence set
- Exploit payloads or instructions that enable misuse

### Scope
In scope:
- Repository scripts/tooling
- CI/workflows and configuration
- Documentation that could cause unsafe handling (e.g., incorrect verification steps)

Out of scope:
- Third-party tools (Wireshark, PCAPdroid, OS components)
- Primary evidence artifacts (treated as immutable)

### Response timeline
- Acknowledgement: typically within 7 days
- Updates: typically every 14 days until resolved or declined
- Fix delivery: `main` first; advisories may document mitigations

This policy is technical only and does not provide legal advice.
```

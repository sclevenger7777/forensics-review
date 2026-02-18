# Contributing

## Purpose
This repository supports independent verification of published forensic artifacts using hashes/manifests and reproducible scripts.

## Non-Goals
- Attribution claims
- Legal conclusions
- Requests to modify primary evidence artifacts

## Evidence immutability
Primary evidence (PCAP/PCAPNG, archives, SHA256 manifests) is immutable.
Pull requests that modify primary evidence will be rejected.

Allowed contributions:
- Documentation improvements
- Deterministic verification scripts
- Derived outputs only if reproducible and accompanied by SHA-256 + generation steps

## Reporting a verification issue
Include:
- Exact filenames
- Expected SHA-256 (from manifest/release)
- Your computed SHA-256 output
- Commands run
- Tool versions (sha256sum, Wireshark/tshark, OS)

## Discussions vs Issues
- Discussions: methodology, boundaries, review questions
- Issues: hash mismatches, reproducibility failures, documentation defects

# Option D — Packet-Level Verification Appendix (Non-Interpretive)

## Purpose and Scope

This appendix provides a strictly packet-level verification of network activity
consistent with BitTorrent protocol behavior, derived from recorded packet
captures. It exists solely to allow independent reviewers to confirm what the
network traffic demonstrates, without reliance on screenshots, narrative
interpretation, or assumptions regarding application intent or user action.

This appendix makes no claims regarding:

- Motivation, intent, or attribution
- Application behavior beyond observable network effects
- Policy, legal, or regulatory implications

Only facts directly verifiable from packet captures and cryptographic hashes are
presented.

## Evidence Basis

All findings in this appendix are derived exclusively from the following artifacts:

- Packet capture: bt_window.pcapng
- Derived summaries:
  - bt_window_ports.txt
  - bt_window_ports_summary_20250917.csv
- Integrity manifest:
  - SHA256SUMS_bt_window_20250917.txt

Each artifact is accompanied by a SHA-256 checksum allowing independent integrity
verification prior to analysis.

## Methodology (Reproducible)

The packet capture was filtered to a bounded time window corresponding to observed
network activity. Derived artifacts were generated using deterministic extraction
scripts included in the appendix. No packet modification, synthesis, or enrichment
was performed.

Verification steps for reviewers:

1. Validate checksums using:

   sha256sum -c SHA256SUMS_bt_window_20250917.txt

2. Inspect port usage and peer activity using:

   - bt_window_ports.txt
   - bt_window_ports_summary_20250917.csv

3. Optionally inspect raw packets directly in bt_window.pcapng using any standard
   packet analysis tool.

All steps are reproducible on a clean system without external dependencies.

## Packet-Level Observations (Factual)

From the verified artifacts, the following packet-level facts are observable:

- Multiple distinct remote peers communicating with the device
- Repeated bidirectional TCP/UDP flows
- Use of port numbers commonly associated with BitTorrent traffic (e.g., 6881–6885, 51413)
- Short-interval connection attempts consistent with peer discovery and exchange
- Temporal clustering of activity within the defined capture window

These observations are presented as network facts only. No inference regarding
application logic or causality is made.

## Review Boundary

This appendix intentionally stops at the packet boundary.

Any conclusions regarding:

- Application responsibility
- User interaction
- Malware classification
- Policy or legal impact

must be drawn separately and are outside the scope of this appendix.

## Reviewer Independence

A reviewer may validate or reject the relevance of these observations solely by
examining the provided packet captures and hashes. No trust in repository authors,
screenshots, or descriptive text is required to reproduce the results.

This appendix exists to provide a stable, citation-safe reference point for
packet-level verification only.

## Derived BitTorrent CSV Summary

For convenience in cross-checking BitTorrent-related flows across the
PCAPdroid-derived CSVs, this repository includes a machine-generated summary:

- File: `evidence/derived/pcap_csv_archive/bittorrent_summary.csv`
- SHA-256:

  ```
  8abacfdeea556947c00b27c632d88f5385922d39ea57b2d245de431ccabe6851
  ```

This artifact is derived by applying a simple filter over the curated
`pcap_csv_archive` CSVs where `protocol == "BitTorrent"`. It is provided
only as a non-interpretive aggregation to simplify packet-level verification.

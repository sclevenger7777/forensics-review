# PCAPdroid-Derived PCAP CSV Archive (HappyMod Window)

This directory contains curated CSV exports derived from PCAPdroid packet
captures associated with the HappyMod investigation window.

## Contents

- `PCAPdroid_*.csv`  
  Raw flow-level CSV exports from PCAPdroid, filtered and curated for the
  Option D packet-level verification.

- `bittorrent_hits.csv`  
  Manually curated subset focusing on flows classified as BitTorrent by
  PCAPdroid.

- `mintegral_hits.csv`  
  Manually curated subset focusing on flows associated with the Mintegral
  ad/telemetry infrastructure (e.g., `configure-tcp.rayjump.com`).

- `bittorrent_summary.csv`  
  Machine-generated aggregation of flows where `protocol == "BitTorrent"`
  across the above CSVs. Intended for cross-checkable, non-interpretive
  packet-level verification, not for legal or policy conclusions.

## bittorrent_summary.csv

- Path (repo-relative):

  ```
  evidence/derived/pcap_csv_archive/bittorrent_summary.csv
  ```

- SHA-256:

  ```
  8abacfdeea556947c00b27c632d88f5385922d39ea57b2d245de431ccabe6851
  ```

- Generation procedure (reproducible):

  1. Ensure the curated source CSVs are present under
     `~/arch/root/pcap_csv_archive` (or another authoritative archive)
     including:

     - `PCAPdroid_13_Sep_22_02_08.csv`
     - `PCAPdroid_17_Aug_20_53_38.csv`
     - `PCAPdroid_22_Jun_18_22_50.csv`
     - `PCAPdroid_24_Jun_21_02_38.csv`
     - `PCAPdroid_28_Jul_01_41_40.csv`
     - `PCAPdroid_28_Jul_06_40_58.csv`
     - `bittorrent_hits.csv`
     - `mintegral_hits.csv`

  2. From within the `forensics-review` repo (Termux):

     ```bash
     cd "/data/data/com.termux/files/home/repos/forensics-review"

     # 2a) Stage curated CSVs into the evidence tree:
     ./stage_and_build_bittorrent_summary.sh

     # 2b) The script will:
     #   - discover the authoritative pcap_csv_archive under $HOME
     #   - copy the CSVs into:
     #       evidence/derived/pcap_csv_archive/
     #   - run:
     #       ./build_bittorrent_summary.sh evidence/derived/pcap_csv_archive
     ```

  3. The resulting `bittorrent_summary.csv` should have SHA-256:

     ```
     8abacfdeea556947c00b27c632d88f5385922d39ea57b2d245de431ccabe6851
     ```

## Scope and Limitations

- This directory and its derived summary are strictly descriptive of observed
  network flows (as represented in the CSV exports).
- No claims are made here regarding user identity, intent, or legality.

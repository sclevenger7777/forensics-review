#!/usr/bin/env bash
#
# install_bittorrent_docs.sh
#
# Idempotent documentation wiring for the curated BitTorrent summary:
#   - evidence/derived/pcap_csv_archive/README.md
#   - references in:
#       OPTION_D_PACKET_LEVEL_VERIFICATION.md
#       README.md
#
# Assumes:
#   - bittorrent_summary.csv already created by build_bittorrent_summary.sh
#   - SHA-256 known / reproducible
#
# Usage:
#   ./install_bittorrent_docs.sh

set -euo pipefail

say() { printf '%s\n' "$*" >&2; }

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  say "ERROR: Must be run from inside the forensics-review repository."
  exit 1
fi
cd "$REPO_ROOT"

BITTORRENT_DIR="$REPO_ROOT/evidence/derived/pcap_csv_archive"
SUMMARY_PATH="$BITTORRENT_DIR/bittorrent_summary.csv"

if [[ ! -f "$SUMMARY_PATH" ]]; then
  say "ERROR: Expected summary not found:"
  say "  $SUMMARY_PATH"
  say "Run stage_and_build_bittorrent_summary.sh first."
  exit 1
fi

SUMMARY_SHA="$(sha256sum "$SUMMARY_PATH" | cut -d' ' -f1)"

say "=== Repo root ==="
say "  $REPO_ROOT"
say ""
say "=== bittorrent_summary.csv ==="
say "  Path: $SUMMARY_PATH"
say "  SHA-256: $SUMMARY_SHA"
say ""

###############################################################################
# 1) evidence/derived/pcap_csv_archive/README.md
###############################################################################

DEST_README="$BITTORRENT_DIR/README.md"
say "=== Writing evidence/derived/pcap_csv_archive/README.md ==="

mkdir -p "$BITTORRENT_DIR"

cat > "$DEST_README" << EOF_INNER
# PCAPdroid-Derived PCAP CSV Archive (HappyMod Window)

This directory contains curated CSV exports derived from PCAPdroid packet
captures associated with the HappyMod investigation window.

## Contents

- \`PCAPdroid_*.csv\`  
  Raw flow-level CSV exports from PCAPdroid, filtered and curated for the
  Option D packet-level verification.

- \`bittorrent_hits.csv\`  
  Manually curated subset focusing on flows classified as BitTorrent by
  PCAPdroid.

- \`mintegral_hits.csv\`  
  Manually curated subset focusing on flows associated with the Mintegral
  ad/telemetry infrastructure (e.g., \`configure-tcp.rayjump.com\`).

- \`bittorrent_summary.csv\`  
  Machine-generated aggregation of flows where \`protocol == "BitTorrent"\`
  across the above CSVs. Intended for cross-checkable, non-interpretive
  packet-level verification, not for legal or policy conclusions.

## bittorrent_summary.csv

- Path (repo-relative):

  \`\`\`
  evidence/derived/pcap_csv_archive/bittorrent_summary.csv
  \`\`\`

- SHA-256:

  \`\`\`
  $SUMMARY_SHA
  \`\`\`

- Generation procedure (reproducible):

  1. Ensure the curated source CSVs are present under
     \`~/arch/root/pcap_csv_archive\` (or another authoritative archive)
     including:

     - \`PCAPdroid_13_Sep_22_02_08.csv\`
     - \`PCAPdroid_17_Aug_20_53_38.csv\`
     - \`PCAPdroid_22_Jun_18_22_50.csv\`
     - \`PCAPdroid_24_Jun_21_02_38.csv\`
     - \`PCAPdroid_28_Jul_01_41_40.csv\`
     - \`PCAPdroid_28_Jul_06_40_58.csv\`
     - \`bittorrent_hits.csv\`
     - \`mintegral_hits.csv\`

  2. From within the \`forensics-review\` repo (Termux):

     \`\`\`bash
     cd "$HOME/repos/forensics-review"

     # 2a) Stage curated CSVs into the evidence tree:
     ./stage_and_build_bittorrent_summary.sh

     # 2b) The script will:
     #   - discover the authoritative pcap_csv_archive under \$HOME
     #   - copy the CSVs into:
     #       evidence/derived/pcap_csv_archive/
     #   - run:
     #       ./build_bittorrent_summary.sh evidence/derived/pcap_csv_archive
     \`\`\`

  3. The resulting \`bittorrent_summary.csv\` should have SHA-256:

     \`\`\`
     $SUMMARY_SHA
     \`\`\`

## Scope and Limitations

- This directory and its derived summary are strictly descriptive of observed
  network flows (as represented in the CSV exports).
- No claims are made here regarding user identity, intent, or legality.
EOF_INNER

say "  Wrote: $DEST_README"
say ""

###############################################################################
# 2) Wire into OPTION_D_PACKET_LEVEL_VERIFICATION.md (if not already)
###############################################################################

OPTION_D="$REPO_ROOT/OPTION_D_PACKET_LEVEL_VERIFICATION.md"
if [[ -f "$OPTION_D" ]]; then
  if grep -q 'bittorrent_summary.csv' "$OPTION_D"; then
    say "=== OPTION_D already references bittorrent_summary.csv; leaving as-is. ==="
  else
    say "=== Appending BitTorrent CSV section to OPTION_D_PACKET_LEVEL_VERIFICATION.md ==="
    cat >> "$OPTION_D" << EOF_INNER

## Derived BitTorrent CSV Summary

For convenience in cross-checking BitTorrent-related flows across the
PCAPdroid-derived CSVs, this repository includes a machine-generated summary:

- File: \`evidence/derived/pcap_csv_archive/bittorrent_summary.csv\`
- SHA-256:

  \`\`\`
  $SUMMARY_SHA
  \`\`\`

This artifact is derived by applying a simple filter over the curated
\`pcap_csv_archive\` CSVs where \`protocol == "BitTorrent"\`. It is provided
only as a non-interpretive aggregation to simplify packet-level verification.
EOF_INNER
  fi
else
  say "WARNING: OPTION_D_PACKET_LEVEL_VERIFICATION.md not found; skipping Option D wiring."
fi
say ""

###############################################################################
# 3) Wire into root README.md (if not already)
###############################################################################

ROOT_README="$REPO_ROOT/README.md"
if [[ -f "$ROOT_README" ]]; then
  if grep -q 'bittorrent_summary.csv' "$ROOT_README"; then
    say "=== Root README already references bittorrent_summary.csv; leaving as-is. ==="
  else
    say "=== Appending Derived BitTorrent Summary section to README.md ==="
    cat >> "$ROOT_README" << EOF_INNER

## Derived BitTorrent Summary (HappyMod Window)

The \`evidence/derived/pcap_csv_archive\` directory contains curated PCAPdroid
CSV exports and a machine-generated BitTorrent summary:

- \`evidence/derived/pcap_csv_archive/bittorrent_summary.csv\`

  - Description: aggregation of rows where \`protocol == "BitTorrent"\` across
    the curated PCAPdroid CSVs for the HappyMod observation window.
  - SHA-256:

    \`\`\`
    $SUMMARY_SHA
    \`\`\`

See \`evidence/derived/pcap_csv_archive/README.md\` for generation steps and
scope limitations.
EOF_INNER
  fi
else
  say "WARNING: README.md not found; skipping README wiring."
fi
say ""

###############################################################################
# 4) Final summary
###############################################################################

say "=== Documentation wiring complete ==="
say "  - $DEST_README"
if [[ -f "$OPTION_D" ]]; then
  say "  - $OPTION_D (BitTorrent section ensured)"
fi
if [[ -f "$ROOT_README" ]]; then
  say "  - $ROOT_README (BitTorrent section ensured)"
fi
say ""
say "You can now review changes via:"
say "  git diff"

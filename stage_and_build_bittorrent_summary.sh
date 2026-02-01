#!/usr/bin/env bash
#
# stage_and_build_bittorrent_summary.sh
#
# Purpose:
#   - Discover the real pcap_csv_archive directory containing PCAPdroid CSVs
#     somewhere under $HOME (no blind guessing of paths).
#   - Stage all *.csv from that archive into:
#         evidence/derived/pcap_csv_archive/
#   - Run build_bittorrent_summary.sh to produce:
#         evidence/derived/pcap_csv_archive/bittorrent_summary.csv
#   - Print the SHA-256 of the summary file.
#
# Usage:
#   ./stage_and_build_bittorrent_summary.sh
#
# Safety:
#   - If zero candidate pcap_csv_archive dirs with CSVs are found -> error.
#   - If more than one candidate -> list them and exit (no guessing).
#   - Original CSVs are never modified; only copied into evidence tree.

set -euo pipefail

say() { printf '%s\n' "$*" >&2; }

# Ensure we are inside the forensics-review repo
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  say "ERROR: Must be run from inside the forensics-review repository."
  exit 1
fi
cd "$REPO_ROOT"

say "=== Repo root ==="
say "  $REPO_ROOT"
say ""

SEARCH_ROOT="$HOME"

say "=== Searching for pcap_csv_archive under ==="
say "  $SEARCH_ROOT (maxdepth 8)"
say ""

# Find candidate pcap_csv_archive directories under $HOME
mapfile -d '' -t candidate_dirs < <(
  find "$SEARCH_ROOT" -maxdepth 8 -type d -name 'pcap_csv_archive' -print0 2>/dev/null || true
)

if (( ${#candidate_dirs[@]} == 0 )); then
  say "ERROR: No directory named 'pcap_csv_archive' found under:"
  say "  $SEARCH_ROOT"
  exit 1
fi

say "Found ${#candidate_dirs[@]} candidate pcap_csv_archive dir(s):"
for d in "${candidate_dirs[@]}"; do
  say "  - $d"
done
say ""

# Filter to only those that actually contain .csv files
valid_dirs=()
for d in "${candidate_dirs[@]}"; do
  shopt -s nullglob
  csvs=("$d"/*.csv)
  shopt -u nullglob
  if (( ${#csvs[@]} > 0 )); then
    valid_dirs+=( "$d" )
  fi
done

if (( ${#valid_dirs[@]} == 0 )); then
  say "ERROR: None of the candidate pcap_csv_archive directories contain any .csv files."
  exit 1
elif (( ${#valid_dirs[@]} > 1 )); then
  say "ERROR: More than one pcap_csv_archive directory with CSVs found."
  say "       Refusing to guess which one is authoritative."
  say "Valid candidates:"
  for d in "${valid_dirs[@]}"; do
    say "  - $d"
  done
  exit 1
fi

SRC_ROOT="${valid_dirs[0]}"

say "=== Selected pcap_csv_archive source ==="
say "  $SRC_ROOT"
say ""

# Destination inside evidence tree
DEST_DIR="$REPO_ROOT/evidence/derived/pcap_csv_archive"
mkdir -p "$DEST_DIR"

say "=== Discovering source CSVs under selected archive ==="
shopt -s nullglob
mapfile -t csv_files < <(find "$SRC_ROOT" -type f -name '*.csv' -print | sort)
shopt -u nullglob

if (( ${#csv_files[@]} == 0 )); then
  say "ERROR: No .csv files found under:"
  say "  $SRC_ROOT"
  exit 1
fi

say "Found ${#csv_files[@]} CSV file(s):"
for f in "${csv_files[@]}"; do
  say "  - $f"
done
say ""

say "=== Staging CSVs into evidence/derived/pcap_csv_archive ==="
for f in "${csv_files[@]}"; do
  base="$(basename "$f")"
  dest="$DEST_DIR/$base"

  if [[ -e "$dest" ]]; then
    say "  [skip] $base (already exists in evidence tree)"
  else
    cp -n -- "$f" "$dest"
    say "  [copy] $base"
  fi
done
say ""

# Sanity check: there should now be CSVs in the evidence tree
shopt -s nullglob
staged_csvs=("$DEST_DIR"/*.csv)
shopt -u nullglob

if (( ${#staged_csvs[@]} == 0 )); then
  say "ERROR: No CSVs present in $DEST_DIR after staging step."
  exit 1
fi

say "=== Staged CSVs in evidence tree ==="
for f in "${staged_csvs[@]}"; do
  say "  - $(basename "$f")"
done
say ""

# Run the existing builder to create bittorrent_summary.csv
BUILD_SCRIPT="$REPO_ROOT/build_bittorrent_summary.sh"

if [[ ! -x "$BUILD_SCRIPT" ]]; then
  say "ERROR: build_bittorrent_summary.sh not found or not executable at:"
  say "  $BUILD_SCRIPT"
  exit 1
fi

say "=== Running build_bittorrent_summary.sh ==="
"$BUILD_SCRIPT" "$DEST_DIR"
say ""

SUMMARY="$DEST_DIR/bittorrent_summary.csv"

if [[ ! -f "$SUMMARY" ]]; then
  say "ERROR: Expected summary not found:"
  say "  $SUMMARY"
  exit 1
fi

say "=== bittorrent_summary.csv created ==="
say "  $SUMMARY"
say ""

say "=== SHA-256 of bittorrent_summary.csv ==="
sha256sum "$SUMMARY"

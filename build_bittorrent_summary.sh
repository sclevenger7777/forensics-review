#!/usr/bin/env bash
#
# build_bittorrent_summary.sh
#
# Aggregate BitTorrent flows from curated PCAPdroid CSVs into a single summary.
#
# Default source:
#   evidence/derived/pcap_csv_archive/*.csv
#
# Output:
#   evidence/derived/pcap_csv_archive/bittorrent_summary.csv
#
# Columns:
#   timestamp_start,src_ip,src_port,dst_ip,dst_port,protocol,hostname,bytes_out,bytes_in
#
# Usage:
#   ./build_bittorrent_summary.sh             # uses default source dir
#   ./build_bittorrent_summary.sh /path/to/csv_dir  # optional override

set -euo pipefail

say() { printf '%s\n' "$*" >&2; }

# Ensure we are inside a git repo (forensics-review)
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  say "ERROR: Must be run from inside the forensics-review repository."
  exit 1
fi
cd "$REPO_ROOT"

# Source directory: default or override from $1
SRC_DIR="${1:-evidence/derived/pcap_csv_archive}"
OUT="$SRC_DIR/bittorrent_summary.csv"

if [[ ! -d "$SRC_DIR" ]]; then
  say "ERROR: Source directory '$SRC_DIR' does not exist."
  say "       Create it and place curated CSVs there, e.g.:"
  say "         $REPO_ROOT/evidence/derived/pcap_csv_archive/*.csv"
  exit 1
fi

# Collect CSV files
shopt -s nullglob
csv_files=("$SRC_DIR"/*.csv)
shopt -u nullglob

if (( ${#csv_files[@]} == 0 )); then
  say "ERROR: No .csv files found under '$SRC_DIR'."
  exit 1
fi

say "Using source CSV directory:"
say "  $SRC_DIR"
say "Files:"
for f in "${csv_files[@]}"; do
  say "  - $(basename "$f")"
done
say ""

# Build summary header
echo "timestamp_start,src_ip,src_port,dst_ip,dst_port,protocol,hostname,bytes_out,bytes_in" > "$OUT"

# Extract BitTorrent rows and map columns:
# Example PCAPdroid row (fields by index):
#   1:  flow id or duration (e.g. 45:17)
#   2:  src_ip
#   3:  src_port
#   4:  dst_ip
#   5:  dst_port
#   6:  uid
#   7:  app_name
#   8:  package
#   9:  protocol (e.g. BitTorrent)
#   10: state
#   11: hostname
#   12: bytes_out
#   13: bytes_in
#   14: pkts_out
#   15: pkts_in
#   16: start_timestamp
#   17: end_timestamp
#
# We use start_timestamp as the summary "timestamp_start".

grep -h ',BitTorrent,' "${csv_files[@]}" \
  | awk -F',' '
    NF >= 16 {
      # strip potential trailing CR
      sub(/\r$/, "", $0);
      printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
        $16,  # timestamp_start
        $2,   # src_ip
        $3,   # src_port
        $4,   # dst_ip
        $5,   # dst_port
        $9,   # protocol
        $11,  # hostname
        $12,  # bytes_out
        $13   # bytes_in
    }
  ' >> "$OUT"

echo "Created summary:"
echo "  $OUT"
echo

sha256sum "$OUT"

#!/usr/bin/env bash
set -u

fail=0

section() {
  printf '\n==== %s ====\n' "$1"
}

note() {
  printf '[NOTE] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1" >&2
}

error() {
  printf '[ERROR] %s\n' "$1" >&2
  fail=1
}

# --- Sanity checks ---------------------------------------------------------

section "Sanity checks"

if [ ! -f "README.md" ] || [ ! -d ".git" ]; then
  error "This does not look like the forensics-review repo root (missing README.md or .git)."
else
  note "Repository root looks OK."
fi

for bin in sha256sum tar head; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    error "Required tool '$bin' is not installed or not in PATH."
  else
    note "Found tool: $bin"
  fi
done

# --- Make helper scripts executable (if present) ---------------------------

section "Ensure helper scripts are executable"

for s in \
  install_bittorrent_docs.sh \
  build_bittorrent_summary.sh \
  stage_and_build_bittorrent_summary.sh \
  install_happymod_apk_docs.sh \
  install_happymod_apk_static_metadata.sh \
  rebuild_happymod_apk_static_metadata.sh
do
  if [ -f "./$s" ]; then
    chmod +x "./$s" || error "Failed to chmod +x $s"
    note "Marked $s as executable."
  else
    note "Script $s not present; skipping."
  fi
done

# --- BitTorrent Evidence Appendix (archive + internal hashes) --------------

BT_ARCHIVE="happymod_bt_evidence_appendix_20250917.tar.gz"
BT_SHA="${BT_ARCHIVE}.sha256"
BT_DIR="happymod_bt_window_20250917_035447"
BT_SUMS_FILE="SHA256SUMS_bt_window_20250917.txt"

section "Step 1 – Verify BitTorrent Evidence Appendix archive"

if [ -f "$BT_ARCHIVE" ] && [ -f "$BT_SHA" ]; then
  note "Found $BT_ARCHIVE and $BT_SHA; running sha256sum -c"
  if ! sha256sum -c "$BT_SHA"; then
    error "BitTorrent appendix archive hash FAILED according to $BT_SHA"
  else
    note "BitTorrent appendix archive hash OK."
  fi
else
  warn "BitTorrent appendix archive and/or .sha256 not present; skipping archive verification."
fi

section "Step 2 – Extract BitTorrent Evidence Appendix"

if [ -f "$BT_ARCHIVE" ]; then
  note "Extracting $BT_ARCHIVE"
  if ! tar -xzf "$BT_ARCHIVE"; then
    error "Failed to extract $BT_ARCHIVE"
  else
    note "Extraction completed (or already extracted)."
  fi
else
  warn "Archive $BT_ARCHIVE not present; skipping extraction."
fi

section "Step 3 – Verify internal BitTorrent appendix hashes"

if [ -d "$BT_DIR" ]; then
  if [ -f "$BT_DIR/$BT_SUMS_FILE" ]; then
    (
      cd "$BT_DIR" || exit 1
      note "Verifying internal SHA256SUMS in $BT_DIR/$BT_SUMS_FILE"
      if ! sha256sum -c "$BT_SUMS_FILE"; then
        error "One or more internal BitTorrent appendix hashes FAILED in $BT_SUMS_FILE"
        exit 1
      fi
    )
    if [ $? -eq 0 ]; then
      note "All internal BitTorrent appendix hashes OK."
    fi
  else
    error "Expected internal sums file $BT_DIR/$BT_SUMS_FILE not found."
  fi
else
  warn "Directory $BT_DIR not found; skipping internal hash verification."
fi

# --- Optional: Minimal review bundle reassembly ----------------------------

section "Optional – Minimal review bundle reassembly"

REASSEMBLER="$(ls REASSEMBLE_forensics_review_minimal_*.sh 2>/dev/null | head -n 1 || true)"

if [ -n "${REASSEMBLER:-}" ]; then
  note "Found reassemble script: $REASSEMBLER"
  chmod +x "$REASSEMBLER" || error "Failed to chmod +x $REASSEMBLER"

  if ls forensics_review_minimal_20260117T141432Z.tar.gz.part_00* >/dev/null 2>&1; then
    note "Minimal bundle parts detected; running $REASSEMBLER"
    if ! "./$REASSEMBLER"; then
      error "Reassemble script failed."
    else
      note "Reassemble script completed."
    fi
  else
    warn "Minimal bundle parts not found; skipping reassembly."
  fi
else
  note "No REASSEMBLE_forensics_review_minimal_*.sh script found; skipping minimal bundle step."
fi

# --- HappyMod APK static metadata integrity + reproducible rebuild ---------

section "Step 4 – Verify HappyMod APK static metadata and reproducible rebuild"

METADATA="evidence/derived/apk_static/happymod_apk_static_metadata.jsonl"
EXPECTED_SHA="57ecdffedc863741b91d8ad0925397f14960029401a9524c01b597fefd242805"
REBUILD_SCRIPT="./rebuild_happymod_apk_static_metadata.sh"

if [ ! -f "$METADATA" ]; then
  warn "Metadata file $METADATA not found. If you have not built it yet, run $REBUILD_SCRIPT once, then re-run this script."
else
  note "Checking existing metadata file hash: $METADATA"
  ACTUAL_SHA="$(sha256sum "$METADATA" | awk '{print $1}')"
  printf 'Existing metadata SHA-256:   %s\n' "$ACTUAL_SHA"
  printf 'Expected metadata SHA-256:   %s\n' "$EXPECTED_SHA"
  if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
    error "Existing metadata SHA-256 does not match expected value."
  else
    note "Existing metadata SHA matches expected value."
  fi
fi

if [ -x "$REBUILD_SCRIPT" ]; then
  note "Running reproducible rebuild: $REBUILD_SCRIPT"
  if ! "$REBUILD_SCRIPT"; then
    error "Rebuild script $REBUILD_SCRIPT failed."
  else
    if [ -f "$METADATA" ]; then
      POST_SHA="$(sha256sum "$METADATA" | awk '{print $1}')"
      printf 'Post-rebuild metadata SHA-256: %s\n' "$POST_SHA"
      printf 'Expected metadata SHA-256:     %s\n' "$EXPECTED_SHA"
      if [ "$POST_SHA" != "$EXPECTED_SHA" ]; then
        error "Post-rebuild metadata SHA-256 mismatch; derivation not stable."
      else
        note "Post-rebuild metadata SHA matches expected value (derivation stable)."
      fi
    else
      error "After rebuild, metadata file $METADATA is missing."
    fi
  fi
else
  warn "Rebuild script $REBUILD_SCRIPT not found or not executable; skipping reproducibility check."
fi

# --- Final status ----------------------------------------------------------

section "Final status"

if [ "$fail" -eq 0 ]; then
  echo "ALL CHECKS COMPLETED SUCCESSFULLY."
  exit 0
else
  echo "ONE OR MORE CHECKS FAILED. See messages above."
  exit 1
fi

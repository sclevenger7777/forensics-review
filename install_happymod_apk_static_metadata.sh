#!/usr/bin/env bash
#
# install_happymod_apk_static_metadata.sh
#
# Derive static metadata for HappyMod APKs referenced in:
#   evidence/raw/apk/happymod_apks.sha256
#
# Outputs:
#   evidence/derived/apk_static/happymod_apk_static_metadata.jsonl
#   evidence/derived/apk_static/README.md
#   evidence/derived/apk_static/<hashprefix>_badging.txt  (if aapt available)
#
# This script is non-destructive and does not touch git or tags.

set -euo pipefail

say() { printf '%s\n' "$*" >&2; }

json_escape() {
  # Minimal JSON string escaper: handles backslash and double-quote.
  # No newlines expected in these fields.
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# --- Repo / path setup -------------------------------------------------------

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  say "ERROR: Must be run from inside the forensics-review repository."
  exit 1
fi

cd "$REPO_ROOT"

RAW_DIR="$REPO_ROOT/evidence/raw/apk"
MANIFEST="$RAW_DIR/happymod_apks.sha256"
OUT_DIR="$REPO_ROOT/evidence/derived/apk_static"
METADATA_JSONL="$OUT_DIR/happymod_apk_static_metadata.jsonl"
README_PATH="$OUT_DIR/README.md"

say "=== Repo root ==="
say "  $REPO_ROOT"
say ""

if [[ ! -f "$MANIFEST" ]]; then
  say "ERROR: Manifest not found:"
  say "  $MANIFEST"
  exit 1
fi

mkdir -p "$OUT_DIR"

# --- Tool detection ----------------------------------------------------------

AAPT_BIN=""
if command -v aapt >/dev/null 2>&1; then
  AAPT_BIN="$(command -v aapt)"
fi

if [[ -n "$AAPT_BIN" ]]; then
  say "=== Static-analysis tool detected ==="
  say "  aapt: $AAPT_BIN"
else
  say "=== WARNING: No aapt found in PATH ==="
  say "Static metadata will be limited to hash + path only."
  say "Install aapt and re-run for richer APK metadata."
fi
say ""

# --- Build metadata JSONL ----------------------------------------------------

say "=== Building static metadata from manifest ==="
say "  Manifest: $MANIFEST"
say "  Output dir: $OUT_DIR"
say ""

: > "$METADATA_JSONL"  # truncate or create

while IFS= read -r line; do
  # Skip empty or comment lines
  if [[ -z "$line" || "$line" = \#* ]]; then
    continue
  fi

  # sha256sum format: "<hash>  <path>"
  hash_val="${line%% *}"
  path="${line#*  }"

  if [[ -z "$hash_val" || -z "$path" ]]; then
    continue
  fi

  # Default statuses
  hash_status="unknown"
  static_status="not_attempted"
  static_tool="none"
  badging_relpath=""

  # Check file existence
  if [[ ! -f "$path" ]]; then
    hash_status="missing"
    static_status="file_missing"
  else
    # Verify SHA-256 against manifest
    current_hash="$(sha256sum "$path" | awk '{print $1}')"
    if [[ "$current_hash" != "$hash_val" ]]; then
      hash_status="mismatch"
      static_status="hash_mismatch"
    else
      hash_status="ok"

      # Only attempt static analysis if hash is OK and tool is present
      if [[ -n "$AAPT_BIN" ]]; then
        static_tool="aapt"
        short_hash="${hash_val:0:12}"
        badging_file="$OUT_DIR/${short_hash}_badging.txt"
        badging_relpath="evidence/derived/apk_static/${short_hash}_badging.txt"

        if "$AAPT_BIN" dump badging "$path" > "$badging_file" 2>&1; then
          static_status="ok"

          # Parse common fields from badging output
          pkg_line="$(grep -m1 '^package: ' "$badging_file" || true)"
          label_line="$(grep -m1 '^application-label:' "$badging_file" || true)"
          sdk_line="$(grep -m1 '^sdkVersion:' "$badging_file" || true)"
          targetsdk_line="$(grep -m1 '^targetSdkVersion:' "$badging_file" || true)"
          perm_count="$(grep -c '^uses-permission:' "$badging_file" || true)"

          pkg_name="$(printf '%s\n' "$pkg_line" | sed -n "s/.*name='\([^']*\)'.*/\1/p")"
          version_code="$(printf '%s\n' "$pkg_line" | sed -n "s/.*versionCode='\([^']*\)'.*/\1/p")"
          version_name="$(printf '%s\n' "$pkg_line" | sed -n "s/.*versionName='\([^']*\)'.*/\1/p")"
          app_label="$(printf '%s\n' "$label_line" | sed -n "s/application-label:'\([^']*\)'.*/\1/p")"
          sdk_version="$(printf '%s\n' "$sdk_line" | sed -n "s/sdkVersion:'\([^']*\)'.*/\1/p")"
          targetsdk_version="$(printf '%s\n' "$targetsdk_line" | sed -n "s/targetSdkVersion:'\([^']*\)'.*/\1/p")"
        else
          static_status="tool_error"
          pkg_name=""
          version_code=""
          version_name=""
          app_label=""
          sdk_version=""
          targetsdk_version=""
          perm_count="0"
        fi
      else
        static_status="tool_missing"
        pkg_name=""
        version_code=""
        version_name=""
        app_label=""
        sdk_version=""
        targetsdk_version=""
        perm_count="0"
      fi
    fi
  fi

  # JSON-escape fields
  j_path="$(json_escape "$path")"
  j_hash="$(json_escape "$hash_val")"
  j_hash_status="$(json_escape "$hash_status")"
  j_static_status="$(json_escape "$static_status")"
  j_static_tool="$(json_escape "$static_tool")"
  j_badging_relpath="$(json_escape "$badging_relpath")"

  j_pkg_name="$(json_escape "${pkg_name:-}")"
  j_version_code="$(json_escape "${version_code:-}")"
  j_version_name="$(json_escape "${version_name:-}")"
  j_app_label="$(json_escape "${app_label:-}")"
  j_sdk_version="$(json_escape "${sdk_version:-}")"
  j_targetsdk_version="$(json_escape "${targetsdk_version:-}")"
  j_perm_count="${perm_count:-0}"

  # Write JSONL record
  printf '{' >> "$METADATA_JSONL"
  printf '"path":"%s",' "$j_path" >> "$METADATA_JSONL"
  printf '"sha256":"%s",' "$j_hash" >> "$METADATA_JSONL"
  printf '"hash_status":"%s",' "$j_hash_status" >> "$METADATA_JSONL"
  printf '"static_tool":"%s",' "$j_static_tool" >> "$METADATA_JSONL"
  printf '"static_status":"%s",' "$j_static_status" >> "$METADATA_JSONL"
  printf '"badging_relpath":"%s",' "$j_badging_relpath" >> "$METADATA_JSONL"
  printf '"package_name":"%s",' "$j_pkg_name" >> "$METADATA_JSONL"
  printf '"version_code":"%s",' "$j_version_code" >> "$METADATA_JSONL"
  printf '"version_name":"%s",' "$j_version_name" >> "$METADATA_JSONL"
  printf '"app_label":"%s",' "$j_app_label" >> "$METADATA_JSONL"
  printf '"sdk_version":"%s",' "$j_sdk_version" >> "$METADATA_JSONL"
  printf '"target_sdk_version":"%s",' "$j_targetsdk_version" >> "$METADATA_JSONL"
  printf '"permission_count":%s' "$j_perm_count" >> "$METADATA_JSONL"
  printf '}\n' >> "$METADATA_JSONL"

done < "$MANIFEST"

say ""
say "=== Static metadata JSONL built ==="
say "  $METADATA_JSONL"
say ""

meta_sha256="$(sha256sum "$METADATA_JSONL" | awk '{print $1}')"

say "SHA-256 of metadata file:"
say "  $meta_sha256"
say ""

# --- Write README for apk_static --------------------------------------------

cat > "$README_PATH" << EOF2
# HappyMod APK Static Metadata (Derived)

This directory contains **derived static metadata** about HappyMod APK artifacts
whose existence and SHA-256 hashes are recorded in:

- \`evidence/raw/apk/happymod_apks.sha256\`

## Contents

- \`happymod_apk_static_metadata.jsonl\`  
  - One JSON object per APK entry from the raw manifest.
  - Fields:
    - \`path\`: absolute filesystem path to the APK at the time of derivation.
    - \`sha256\`: SHA-256 recorded in the raw manifest.
    - \`hash_status\`:
      - \`ok\`: file exists and matches the recorded SHA-256.
      - \`missing\`: file not found at the recorded path.
      - \`mismatch\`: file exists but hash no longer matches the manifest.
    - \`static_tool\`: tool used for static extraction (e.g. \`aapt\`, or \`none\`).
    - \`static_status\`:
      - \`ok\`: static tool ran successfully on the verified APK.
      - \`file_missing\`: no file at the recorded path.
      - \`hash_mismatch\`: file present but SHA-256 differs; static analysis skipped.
      - \`tool_missing\`: no suitable static tool available at derivation time.
      - \`tool_error\`: static tool returned an error.
    - \`badging_relpath\`: relative path to raw tool output (if available).
    - \`package_name\`, \`version_code\`, \`version_name\`, \`app_label\`,
      \`sdk_version\`, \`target_sdk_version\`: parsed from static tool output
      (when available).
    - \`permission_count\`: number of \`uses-permission\` entries observed.

- \`<hashprefix>_badging.txt\` (optional, one per APK)
  - Raw output of \`aapt dump badging <apk>\`, where \`<hashprefix>\` is the
    first 12 hex characters of the APK's SHA-256 recorded in the raw manifest.
  - These files are provided for independent re-parsing and verification.

## Build Procedure

This directory is generated by running, from the repository root:

\`\`\`bash
./install_happymod_apk_static_metadata.sh
\`\`\`

Prerequisites:

- The raw APK manifest must already exist:
  - \`evidence/raw/apk/happymod_apks.sha256\`
- (Optional, recommended) \`aapt\` installed and available in \`PATH\`.
  - When \`aapt\` is missing, static fields are left empty and \`static_status\`
    is set to \`tool_missing\`.

Re-running the installer script will:

- Recompute \`happymod_apk_static_metadata.jsonl\` from the current manifest and
  live files.
- Regenerate this README to reflect the latest metadata SHA-256.

## Current Metadata Integrity

- File: \`evidence/derived/apk_static/happymod_apk_static_metadata.jsonl\`
- SHA-256: \`${meta_sha256}\`

## Scope

This directory is **derived, non-interpretive evidence**. It summarizes what can
be learned from static inspection of the APK binaries and their manifest entries
(package name, version, SDK levels, declared permissions, etc.), conditioned on
the raw hash manifest.

It does **not** assert anything about:

- Runtime behavior of the APKs
- User intent or attribution
- Legal or policy conclusions

Those questions must be addressed, if at all, in higher-level analysis that
references these static facts.

EOF2

say "=== README written ==="
say "  $README_PATH"
say ""
say "=== Done. Static HappyMod APK metadata derivation completed. ==="
say "Metadata file:"
say "  $METADATA_JSONL"
say "SHA-256:"
say "  $meta_sha256"

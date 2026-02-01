#!/usr/bin/env bash
#
# rebuild_happymod_apk_static_metadata.sh
#
# Rebuilds derived static metadata for HappyMod APKs based on:
#   evidence/raw/apk/happymod_apks.sha256
#
# Output:
#   evidence/derived/apk_static/happymod_apk_static_metadata.jsonl
#   evidence/derived/apk_static/<sha12>_badging.txt
#   evidence/derived/apk_static/README.md

set -euo pipefail

say() { printf '%s\n' "$*" >&2; }

# Ensure we are inside the forensics-review repo
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  say "ERROR: Must be run from inside the forensics-review repository."
  exit 1
fi
cd "$REPO_ROOT"

MANIFEST="evidence/raw/apk/happymod_apks.sha256"
OUT_JSONL="evidence/derived/apk_static/happymod_apk_static_metadata.jsonl"
OUT_DIR="$(dirname "$OUT_JSONL")"

mkdir -p "$OUT_DIR"

say "=== Repo root ==="
say "  $REPO_ROOT"
say
say "=== Manifest ==="
say "  $MANIFEST"
say "=== Output JSONL ==="
say "  $OUT_JSONL"
say

if [[ ! -f "$MANIFEST" ]]; then
  say "ERROR: Manifest not found at: $MANIFEST"
  exit 1
fi

STATIC_TOOL="none"
if command -v aapt >/dev/null 2>&1; then
  STATIC_TOOL="aapt"
  say "=== Static-analysis tool detected ==="
  say "  aapt: $(command -v aapt)"
  say
else
  say "WARNING: aapt not found; static metadata fields will be omitted."
  say
fi

# JSON escaping for string fields
json_escape() {
  # escape backslash and double quote
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# Truncate output JSONL
: > "$OUT_JSONL"

# Main loop over manifest lines
while read -r sha256 path; do
  # Skip blank lines and comments
  [[ -z "${sha256:-}" ]] && continue
  case "$sha256" in
    \#*) continue ;;
  esac

  if [[ -z "${path:-}" ]]; then
    continue
  fi

  hash_status="missing"
  static_status="not_run"
  badging_relpath=""
  package_name=""
  version_code=""
  version_name=""
  app_label=""
  sdk_version=""
  target_sdk_version=""
  permission_count=0

  if [[ ! -f "$path" ]]; then
    hash_status="missing_file"
  else
    # Verify SHA-256
    actual_sha="$(sha256sum "$path" | awk '{print $1}')"
    if [[ "$actual_sha" == "$sha256" ]]; then
      hash_status="ok"
    else
      hash_status="mismatch"
    fi

    # Static analysis via aapt
    if [[ "$STATIC_TOOL" == "aapt" ]]; then
      sha_prefix="${sha256:0:12}"
      badging_file="$OUT_DIR/${sha_prefix}_badging.txt"

      if [[ ! -f "$badging_file" ]]; then
        say "--- Running aapt dump badging for ---"
        say "  $path"
        aapt dump badging "$path" > "$badging_file" 2>/dev/null || true
      else
        say "--- Reusing existing badging file for ---"
        say "  $path"
        say "  $badging_file"
      fi

      if [[ -s "$badging_file" ]]; then
        static_status="ok"
        badging_relpath="${badging_file#"$REPO_ROOT/"}"

        # Parse fields from aapt badging output

        # package: name='com.happymod.apk' versionCode='257' versionName='3.1.7' ...
        pkg_line="$(grep -m1 '^package: ' "$badging_file" || true)"
        if [[ -n "$pkg_line" ]]; then
          package_name="$(printf '%s\n' "$pkg_line" | grep -o "name='[^']*'" | head -1 | sed "s/.*name='\([^']*\)'.*/\1/")"
          version_code="$(printf '%s\n' "$pkg_line" | grep -o "versionCode='[^']*'" | head -1 | sed "s/.*versionCode='\([^']*\)'.*/\1/")"
          version_name="$(printf '%s\n' "$pkg_line" | grep -o "versionName='[^']*'" | head -1 | sed "s/.*versionName='\([^']*\)'.*/\1/")"
        fi

        # sdkVersion:'21'
        sdk_line="$(grep -m1 '^sdkVersion:' "$badging_file" || true)"
        if [[ -n "$sdk_line" ]]; then
          sdk_version="$(printf '%s\n' "$sdk_line" | sed "s/.*'\([^']*\)'.*/\1/")"
        fi

        # targetSdkVersion:'31'
        tsdk_line="$(grep -m1 '^targetSdkVersion:' "$badging_file" || true)"
        if [[ -n "$tsdk_line" ]]; then
          target_sdk_version="$(printf '%s\n' "$tsdk_line" | sed "s/.*'\([^']*\)'.*/\1/")"
        fi

        # application-label:'HappyMod'
        label_line="$(grep -m1 '^application-label:' "$badging_file" || true)"
        if [[ -n "$label_line" ]]; then
          app_label="$(printf '%s\n' "$label_line" | sed "s/.*'\([^']*\)'.*/\1/")"
        fi

        # Count permissions
        permission_count=$(grep -c '^uses-permission:' "$badging_file" || true)
      else
        static_status="empty_badging"
      fi
    fi
  fi

  esc_path="$(json_escape "$path")"
  esc_badging_relpath="$(json_escape "$badging_relpath")"
  esc_package_name="$(json_escape "$package_name")"
  esc_version_code="$(json_escape "$version_code")"
  esc_version_name="$(json_escape "$version_name")"
  esc_app_label="$(json_escape "$app_label")"
  esc_sdk_version="$(json_escape "$sdk_version")"
  esc_target_sdk_version="$(json_escape "$target_sdk_version")"

  printf '{"path":"%s","sha256":"%s","hash_status":"%s","static_tool":"%s","static_status":"%s","badging_relpath":"%s","package_name":"%s","version_code":"%s","version_name":"%s","app_label":"%s","sdk_version":"%s","target_sdk_version":"%s","permission_count":%s}\n' \
    "$esc_path" \
    "$sha256" \
    "$hash_status" \
    "$STATIC_TOOL" \
    "$static_status" \
    "$esc_badging_relpath" \
    "$esc_package_name" \
    "$esc_version_code" \
    "$esc_version_name" \
    "$esc_app_label" \
    "$esc_sdk_version" \
    "$esc_target_sdk_version" \
    "$permission_count" \
    >> "$OUT_JSONL"

done < "$MANIFEST"

# Write/update README for derived static metadata
README="$OUT_DIR/README.md"
cat > "$README" <<EOF2
# Derived HappyMod APK Static Metadata

This directory contains static-analysis artifacts derived from the HappyMod APKs
listed in \`evidence/raw/apk/happymod_apks.sha256\`.

## Files

- \`happymod_apk_static_metadata.jsonl\` — one JSON object per APK path, including:
  - original filesystem path and SHA-256
  - hash verification status (\`ok\`, \`mismatch\`, or \`missing_file\`)
  - basic static metadata from \`aapt dump badging\` (when available)
  - relative path to the captured \`aapt\` badging text (if present)

- \`<sha12>_badging.txt\` — raw \`aapt dump badging\` output for each distinct APK hash.

Current metadata file SHA-256:

\`\`\`
$(sha256sum "$OUT_JSONL" | awk '{print $1}')
\`\`\`

This directory is **non-interpretive**: it records static characteristics of the
APK artifacts at the time of generation but does not assert any behavioral or
legal conclusion.

EOF2

say
say "=== Static metadata JSONL rebuilt ==="
say "  $OUT_JSONL"
say
say "SHA-256 of metadata file:"
sha256sum "$OUT_JSONL"

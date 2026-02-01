# Derived HappyMod APK Static Metadata

This directory contains static-analysis artifacts derived from the HappyMod APKs
listed in `evidence/raw/apk/happymod_apks.sha256`.

## Files

- `happymod_apk_static_metadata.jsonl` — one JSON object per APK path, including:
  - original filesystem path and SHA-256
  - hash verification status (`ok`, `mismatch`, or `missing_file`)
  - basic static metadata from `aapt dump badging` (when available)
  - relative path to the captured `aapt` badging text (if present)

- `<sha12>_badging.txt` — raw `aapt dump badging` output for each distinct APK hash.

Current metadata file SHA-256:

```
57ecdffedc863741b91d8ad0925397f14960029401a9524c01b597fefd242805
```

This directory is **non-interpretive**: it records static characteristics of the
APK artifacts at the time of generation but does not assert any behavioral or
legal conclusion.


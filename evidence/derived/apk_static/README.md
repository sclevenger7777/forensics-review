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

- `libchecker_webui_happymod_20260910T070139Z.md` — derived static-analysis
  note from a LibChecker WebUI browser-local APK analyzer export for
  `happymod_base.apk`. This artifact records APK identity, permissions,
  native libraries, SDK-rule detections, BitTorrent/download-named components,
  background-work components, and signing metadata.

- `libchecker_webui_happymod_20260910T070139Z.json.sha256` — SHA-256 digest
  for the LibChecker WebUI JSON export supplied during the review session.

Current metadata file SHA-256:

```
57ecdffedc863741b91d8ad0925397f14960029401a9524c01b597fefd242805
```

LibChecker WebUI JSON export SHA-256:

```
c0b81838650e96af0957225a97f3970a3f2b46f3f44ffdff1b989884d780ad09
```

## LibChecker WebUI artifact

The LibChecker WebUI artifact was generated with `https://lc.absinthe.life/`.
The export identifies its analyzer profile as `browser-local-apk-analyzer` and
reports browser-local APK-analysis capabilities including manifest parsing,
resource inspection, native-library inventory, APK signature inspection, DEX
feature markers, and LibChecker SDK-rule matching.

Key non-interpretive findings recorded from that export include:

- APK identity: `HappyMod`, `com.happymod.apk`, version `3.1.7`, version code
  `257`, file `happymod_base.apk`, size `19721997` bytes.
- Native `jlibtorrent` detection: `libjlibtorrent-1.2.15.2.so` under both
  `arm64-v8a` and `armeabi-v7a`, detected by `regex_jlibtorrent`.
- BitTorrent/download-named components including
  `btdownload.gui.view.TorrentGetActivity`, `btdownload.services.EngineService`,
  `btdownload.services.statistics.WorkService`, and
  `btdownload.services.EngineBroadcastReceiver`.
- `btdownload.services.EngineBroadcastReceiver` reports
  `android.intent.action.BOOT_COMPLETED`.
- Background/scheduled-work capability indicators including Jetpack WorkManager
  services and receivers.
- Advertising/telemetry SDK surface including Firebase, Firebase Analytics,
  Unity Ads, Google Play Services, UMENG metadata, and Google Ads application
  metadata.

This directory is **non-interpretive**: it records static characteristics of the
APK artifacts at the time of generation but does not assert any behavioral,
malware, developer-intent, user-intent, legal, or policy conclusion.


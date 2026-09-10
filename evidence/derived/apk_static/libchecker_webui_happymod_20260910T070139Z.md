# LibChecker WebUI HappyMod APK Static Artifact — 2026-09-10

This file records a derived static-analysis artifact generated from a HappyMod APK using **LibChecker WebUI** (`lc.absinthe.life`). The uploaded source export identifies its analyzer profile as `browser-local-apk-analyzer` and reports browser-local Android APK analysis capabilities.

## Source artifact

- Source file name: `com.happymod.apk (1).json`
- Analyzer profile ID: `browser-local-apk-analyzer`
- Public tool attribution: **LibChecker WebUI**
- Tool URL: `https://lc.absinthe.life/`
- Analysis timestamp: `2026-09-10T07:01:39.310Z`
- Analysis environment reported by export: Android `16.0.0`
- Export SHA-256, as preserved in the working review session: `c0b81838650e96af0957225a97f3970a3f2b46f3f44ffdff1b989884d780ad09`
- Export byte count, as preserved in the working review session: `163397`

The JSON export itself was provided as a review-session source artifact. This Markdown record extracts the non-interpretive findings relevant to the existing HappyMod evidence chain.

## Analyzer capabilities reported by the export

The export reports the following capabilities:

- manifest parsing
- resource inspection
- native-library inventory
- APK signature inspection
- DEX feature markers
- LibChecker SDK-rule matching

Reported analyzer statistics:

- rule count: `2736`
- icon count: `172`
- unique SDK count: `13`
- SDK marker count: `40`
- native SDK marker count: `1`
- component SDK marker count: `39`
- duration: `138 ms`

## APK identity

The analyzed APK is reported as:

- app name: `HappyMod`
- package name: `com.happymod.apk`
- version name: `3.1.7`
- version code: `257`
- min SDK: `21`
- target SDK: `31`
- compile SDK: `33`
- file name: `happymod_base.apk`
- file size: `19721997` bytes

## Permission surface

The export reports the following declared permissions:

- `android.permission.ACCESS_ADSERVICES_AD_ID`
- `android.permission.ACCESS_ADSERVICES_ATTRIBUTION`
- `android.permission.ACCESS_NETWORK_STATE`
- `android.permission.ACCESS_WIFI_STATE`
- `android.permission.CAMERA`
- `android.permission.FOREGROUND_SERVICE`
- `android.permission.INTERNET`
- `android.permission.MANAGE_EXTERNAL_STORAGE`
- `android.permission.MODIFY_AUDIO_SETTINGS`
- `android.permission.QUERY_ALL_PACKAGES`
- `android.permission.READ_EXTERNAL_STORAGE`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.RECORD_AUDIO`
- `android.permission.REQUEST_INSTALL_PACKAGES`
- `android.permission.SCHEDULE_EXACT_ALARM`
- `android.permission.WAKE_LOCK`
- `android.permission.WRITE_EXTERNAL_STORAGE`
- `com.android.launcher.permission.FOREGROUND_SERVICE`
- `com.android.launcher.permission.INSTALL_SHORTCUT`
- `com.android.launcher.permission.READ_SETTINGS`
- `com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE`
- `com.google.android.gms.permission.AD_ID`
- `com.happymod.apk.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`

## Native libraries

The export reports native libraries for `arm64-v8a`, `armeabi-v7a`, and `x86`.

Relevant reported native libraries include:

- `lib/arm64-v8a/libCSTAMP.so`, size `14296`
- `lib/arm64-v8a/libHappymodPrincess.so`, size `10320`
- `lib/arm64-v8a/libjlibtorrent-1.2.15.2.so`, size `7290024`
- `lib/armeabi-v7a/libCSTAMP.so`, size `9064`
- `lib/armeabi-v7a/libHappymodPrincess.so`, size `13752`
- `lib/armeabi-v7a/libjlibtorrent-1.2.15.2.so`, size `8674128`
- `lib/x86/libCSTAMP.so`, size `11956`
- `lib/x86/libHappymodPrincess.so`, size `9596`

## LibChecker SDK-rule detection: jlibtorrent

The export reports a native SDK marker for `jlibtorrent`:

- label: `jlibtorrent`
- match source: `regex`
- regex name: `regex_jlibtorrent`
- detail key: `0::regex/regex_jlibtorrent`
- rule path: `native-libs/regex/regex_jlibtorrent.json`
- count: `1`
- file count: `2`
- ABIs: `arm64-v8a`, `armeabi-v7a`
- preview item: `libjlibtorrent-1.2.15.2.so`

The rule metadata represented in the export describes `jlibtorrent` as FrostWire's SWIG Java interface for libtorrent.

## BitTorrent-named components

The export reports APK components with BitTorrent/download-engine naming:

- activity: `btdownload.gui.view.TorrentGetActivity`
- service: `btdownload.services.EngineService`
- service: `btdownload.services.statistics.WorkService`
- receiver: `btdownload.services.EngineBroadcastReceiver`

The receiver `btdownload.services.EngineBroadcastReceiver` is reported with action:

- `android.intent.action.BOOT_COMPLETED`

## Background and scheduled-work components

The export reports Jetpack WorkManager components including:

- `androidx.work.impl.background.systemalarm.SystemAlarmService`
- `androidx.work.impl.background.systemjob.SystemJobService`
- `androidx.work.impl.foreground.SystemForegroundService`
- `androidx.work.impl.utils.ForceStopRunnable$BroadcastReceiver`
- `androidx.work.impl.background.systemalarm.RescheduleReceiver`
- `androidx.work.impl.background.systemalarm.ConstraintProxy$NetworkStateProxy`

The export's SDK summary identifies Jetpack WorkManager as `Receiver 8 · Service 3`.

## Additional SDK / telemetry surface reported

The export reports SDK/component markers including:

- Firebase
- Firebase Analytics
- Unity Ads
- Google Play Services
- Jetpack App Startup
- Jetpack ProfileInstaller
- Jetpack Room
- PictureSelector
- FileDownloader
- uCrop
- File Provider

Application metadata reported by the export includes:

- `ScopedStorage=true`
- `com.facebook.sdk.AutoLogAppEventsEnabled=false`
- `UMENG_APPKEY=5ab20f4ff43e4820ca000225`
- `UMENG_CHANNEL=HappyMod`
- `com.google.android.gms.ads.APPLICATION_ID=ca-app-pub-9980751151906239~6293987247`

## Signature metadata

The export reports APK signature schemes:

- V1
- V2
- V3

Certificate metadata reported by the export:

- issuer: `O=evz`
- subject: `O=evz`
- serial number: `1038879172` / `0x3dec09c4`
- validity start: `2018-03-15T08:11:53.000Z`
- validity end: `2118-02-19T08:11:53.000Z`
- public key algorithm: RSA
- modulus size: 2048 bits
- signature algorithm: `SHA256withRSA`
- source entry: `META-INF/HAPPYMOD.RSA`
- MD5 fingerprint: `EB:3C:65:64:A7:A7:F8:33:2A:98:BD:9C:13:98:22:D4`
- SHA-1 fingerprint: `8F:16:D0:F9:EA:B6:FF:B4:CC:EF:61:5C:7A:6B:01:52:10:E0:9B:1F`
- SHA-256 fingerprint: `C3:84:6F:1B:45:B5:79:E6:94:F1:35:53:F5:D7:AE:45:61:5B:AC:95:64:7F:8E:D8:BD:76:C9:15:3E:F4:E0:D3`

## Scope and limitations

This artifact is static analysis. It records APK structure, declared permissions, component names, native-library inventory, signing metadata, and SDK-rule detections as represented by LibChecker WebUI / `browser-local-apk-analyzer`.

This artifact does not, by itself, assert:

- runtime execution of any specific code path;
- user intent;
- developer intent;
- legal conclusions;
- malware classification.

Its evidentiary value is strongest when read alongside the PCAPdroid-derived app/UID-attributed BitTorrent flow rows and the packet-level BT-DHT artifacts already present in this repository.

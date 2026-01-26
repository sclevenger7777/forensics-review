# forensics-review

Private forensic review repository containing network-capture evidence and
verification artifacts related to observed BitTorrent traffic associated with
the HappyMod application environment.

---

# START HERE — HappyMod BitTorrent Evidence (Reproducible)

This repository provides materials for independent forensic review of
unsolicited BitTorrent network activity observed on an Android device.

The activity was captured during packet-level network monitoring using
PCAPdroid while testing a custom-developed Android application.

All findings presented here are derived exclusively from packet captures,
cryptographic hashes, and reproducible extraction scripts. All material facts
can be verified directly from the evidence provided in this repository.

---

## Recommended Review Order

| Order | Component                    | Evidence Class        | Notes                          |
|------:|------------------------------|-----------------------|--------------------------------|
| 1     | BitTorrent Evidence Appendix | Derived, Reproducible | Packet-level confirmation      |
| 2     | HappyMod Evidence Bundle     | Immutable             | Original acquisition           |
| 3     | Manifests & Verification     | Integrity Proof       | Hash and tree validation       |
| 4     | Regulatory Correspondence    | Contextual            | Optional supporting material   |

Most reviewers should begin with the BitTorrent Evidence Appendix. It provides
a concise, packet-level confirmation of the activity visible in the PCAPdroid
screenshots without requiring inspection of the full evidence bundle.

---

## Prerequisite — Download Review Artifacts

From this repository’s **Releases** section, download the following files.

Minimal review bundle (full context, optional for Steps 1–4):

- forensics_review_minimal_20260117T141432Z.tar.gz.part_000
- forensics_review_minimal_20260117T141432Z.tar.gz.part_001
- forensics_review_minimal_20260117T141432Z.tar.gz.part_002
- forensics_review_minimal_20260117T141432Z.tar.gz.part_003
- forensics_review_minimal_20260117T141432Z.tar.gz.part_004
- forensics_review_minimal_20260117T141432Z.tar.gz.part_005
- forensics_review_minimal_20260117T141432Z.tar.gz.sha256
- REASSEMBLE_forensics_review_minimal_20260117T141432Z.sh

BitTorrent Evidence Appendix (required for Steps 1–4):

- happymod_bt_evidence_appendix_20250917.tar.gz
- happymod_bt_evidence_appendix_20250917.tar.gz.sha256

---

## Optional — Reassemble the Minimal Review Bundle

This step is only required if you intend to inspect the full HappyMod evidence
bundle referenced in Step 5.

Place all forensics_review_minimal_20260117T141432Z.tar.gz.part_00* files,
the .sha256 file, and the REASSEMBLE script into the same directory, then run:

chmod +x REASSEMBLE_forensics_review_minimal_20260117T141432Z.sh  
./REASSEMBLE_forensics_review_minimal_20260117T141432Z.sh  

If desired, extract the resulting archive:

tar -xzf forensics_review_minimal_20260117T141432Z.tar.gz

This produces a directory tree rooted at:

Forensics_REVIEW_READY/

---

## Step 1 — Verify the BitTorrent Evidence Appendix

Verify the appendix archive integrity:

sha256sum -c happymod_bt_evidence_appendix_20250917.tar.gz.sha256

The command must report OK.

---

## Step 2 — Extract the Appendix

Extract the appendix archive:

tar -xzf happymod_bt_evidence_appendix_20250917.tar.gz

This will create:

happymod_bt_window_20250917_035447/  
happymod_contextual_screenshots_20250917/  
happymod_contextual_appendix_20250917.txt  

---

## Step 3 — Verify Derived BitTorrent Artifacts

Change into the BitTorrent window directory:

cd happymod_bt_window_20250917_035447

Verify internal hashes:

sha256sum -c SHA256SUMS_bt_window_20250917.txt

All entries must report OK.

Verified artifacts include:

bt_window_all.txt  
bt_window_ports.txt  
bt_window.pcapng  
bt_window_ports_summary_20250917.csv  
README_bt_window_20250917.txt  
create_bt_window_summary_20250917.sh  

---

## Step 4 — Review Packet-Level BitTorrent Activity

Primary review targets:

bt_window_ports_summary_20250917.csv  
Aggregated view of BitTorrent-typical UDP activity by peer address, port, and
traffic direction within the defined time window.

bt_window_ports.txt  
Line-by-line packet listing showing timestamps, source and destination IPs,
ports, and frame lengths.

bt_window.pcapng  
Raw packet capture for the same time window, suitable for independent analysis
using Wireshark or tshark.

Example inspection commands:

head bt_window_ports_summary_20250917.csv  
head bt_window_ports.txt  

Timestamps correspond directly to the PCAPdroid screenshots located in:

../happymod_contextual_screenshots_20250917/

---

## Step 5 — Full Evidence Bundle (Optional)

The BitTorrent Evidence Appendix is derived exclusively from files contained
within the HappyMod Evidence Bundle. No external data sources were used.

The full bundle includes:

- Original PCAPdroid and related packet captures
- Hash manifests (including inner_manifest.sha256)
- Verification logs (e.g. verify_inner_20251231T080138Z.log)
- Tree-based hash validation files
- Case-level documentation (timeline.md, summary.md, sources.md)

Using these materials, a reviewer can independently:

- Verify bundle integrity
- Locate the original staged capture used for derivation
- Re-run the extraction commands
- Reproduce the BitTorrent window and summaries exactly

---

## Evidence Handling Notes

The BitTorrent Evidence Appendix is derived evidence intended for efficient,
packet-level verification.

The HappyMod Evidence Bundle is the immutable primary evidence source.

Manifest and hash files provide integrity guarantees only; they do not assert
interpretation.

Contextual or regulatory materials do not alter evidentiary weight.

All conclusions are derived directly from packet captures and cryptographic
verification artifacts.

---

## Intended Audience

This repository is intended for:

- Network forensics analysts
- Security researchers
- Platform trust and safety teams
- Compliance and regulatory reviewers

---

## Reproducibility Statement

Any qualified reviewer with access to this repository can:

- Verify all cryptographic hashes
- Recreate the BitTorrent activity window from the original capture
- Regenerate all derived summaries
- Independently confirm correspondence between UI screenshots and packet data

The purpose of this repository is to enable that process end-to-end.

---

## License

Original analysis scripts are MIT licensed. Evidence files consist of raw packet
data and cryptographic hashes representing factual observations.

---

## Contributing

This repository is maintained as a read-only forensic record. Issues are welcome
for clarification or reproducibility questions. No direct modifications to
evidence or scripts are accepted.

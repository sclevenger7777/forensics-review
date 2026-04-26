# HappyMod BT-DHT Packet Window — 2025-09-17

## Purpose

This directory contains the isolated packet window used for independent packet-level verification of BitTorrent DHT traffic.

## Files

- `bt_window.pcapng` — isolated packet capture window
- `bt_window.pcapng.sha256` — SHA-256 checksum for the packet capture
- `README.md` — this description

## Verified packet capture

SHA-256:

`bfad00f60f162b7990883ad28c8efbbac1e0d0776babc3e75f331abf97276112`

## Verification scope

This artifact is intended to answer one narrow question:

Does the raw packet capture contain BitTorrent DHT traffic at the packet level?

It does not assert intent, attribution, malware classification, legal conclusions, or application developer knowledge.

## Expected tshark/Wireshark result

A correct verification should identify BT-DHT packets including:

- `BT-DHT Get_peers Info_hash=...`
- `BT-DHT Response Nodes=...`

Known local endpoint observed in verification:

- `10.215.173.1:43883`

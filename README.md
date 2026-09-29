# Phantom-Sync
PhantomSync — Menu-driven Windows profiling payload for USB Rubber Ducky 3.0. Four modes: full profile, network, user audit, process inventory. Writes timestamped reports to Ducky mass storage. No network, no persistence, no destructive actions. DuckyScript 3.0, Windows 10/11.
# PhantomSync

A menu-driven Windows system profiling payload for the USB Rubber Ducky 3.0.
Collects system, network, user, and process inventory and writes a single
timestamped report to the Ducky's mass-storage partition. No network access,
no external dependencies, no destructive actions.

## Target
- Windows 10 / Windows 11
- USB Rubber Ducky 3.0 (DuckyScript 3.0)
- Partial compatibility with O.MG Cable in DuckyScript 3.0 mode if mass storage is enabled

## What it does
Presents an interactive menu with four profiling modes:
1. Full profile (system + network + users + processes)
2. Network only (adapters, routes, DNS, ARP, established connections)
3. User and session audit (local users, active sessions, admin group)
4. Process and service inventory (top CPU, running services, ready tasks)

Output is written to `loot/<COMPUTERNAME>_<YYYYMMDD_HHMMSS>.txt` on the first
available filesystem drive (expected to be the Ducky's mass-storage partition).

## Design notes
- All PowerShell logic is delivered as a single base64-encoded `-EncodedCommand`
  argument. This avoids keystroke-drop and timing failures that affect
  multi-line DuckyScript payloads.
- No network calls. No persistence. No credential access. No file modification
  outside the Ducky's own storage.
- Follows the Hak5 payload style guide (REM header, DEFINE constants).

## Usage
1. Flash `payload.txt` to your Rubber Ducky via the Payload Studio or the
   Ducky's mass-storage copy method.
2. Insert into a Windows 10/11 target.
3. Wait for the PowerShell window to appear, then select a menu option.
4. Eject the Ducky and read `loot/` from its storage partition.

## Compatibility
| Device | Status |
|---|---|
| USB Rubber Ducky 3.0 | Native |
| O.MG Cable (DuckyScript 3.0 mode) | Partial — requires mass storage enabled |
| Flipper Zero BadUSB | Not compatible — DuckyScript 1.0 only |

## Author
<your_handle>

## Version
2.0

## License
Use only on systems you own or have explicit written authorization to test.

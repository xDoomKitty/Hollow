# Native 0.69 validation

September 20, 2026. Godot 4.5.1 stable on the hosted Linux workstation.

- Simulation: **78 groups, 2,069 assertions, zero failures**. New coverage verifies read-only cargo manifests, actual owner identities and quantities, hidden and unopened containers, worn equipment, search, physical multi-floor regrouping, pause, cancellation, save recovery, busy/queued/drafted/downed colonists, blocked stairs and intermediate story gates. Prior native saves and the entire campaign remain covered.
- Native headless input/layout: **1,670 assertions, zero failures**: 1,545 campaign checks, 61 direct interaction/gesture checks and 64 expedition checks. Real viewport input verifies crew dragging without unintended orders, cross-floor selection, paused regrouping, cargo search and filters, owner lookup, remembered storage, remote-map order rejection and Follow. Crew/cargo layouts are checked at 844×390, 960×540 and 1280×800 window sizes using the project's canvas stretch settings. These are headless checks, not graphical or physical device approval.
- `python3 tools/build.py --android`: import, simulation, native QA and Android/Windows/Linux exports passed. Exported Linux starts headlessly with embedded resources.
- Android **0.69.0 / code 69** uses package `com.hollow.colony.prototype`, minimum API 24 and target API 35. APK Signature Schemes v2/v3 verify with the preserved certificate SHA-256 `df7193174d83fa04c2be605ebcfb4c989c302fc714705674b449d3b60cbdef62`. The APK has no Internet permission. `tools/verify_android_signing.py` refuses an absent or mismatched key.
- GitHub's initial source import was read back and all 49 source blob identities plus the complete 71-commit recovery bundle matched. The setup commit was retained. Original commits remain in the bundle pending approved attachment to branch history; no GitHub Actions workflow is installed.
- The 0.69 code commit `778d48d67ffd254c05bc2e4d6f35e3e94d7d011f` was published and all 55 file hashes/modes matched on readback. Recovery again restored the current GitHub files and the preserved native history. Package archive integrity, notices, signatures and saved-download replacements were checked before delivery.

Graphical QA was attempted: X11 and Wayland could not initialize; Xvfb is unavailable. `adb devices -l` reports no attached devices. Actual Android/Windows execution, rendering, sound, touch comfort, update installation, performance and battery behavior remain unverified.

No new raster art, audio or third-party dependency is required. The overview uses original code-native controls; existing original asset generators and engine notices remain. This is a prototype, not a store-ready release.

# Native 0.70 validation

September 20, 2026. Godot 4.5.1 stable on the hosted Linux workstation.

- Simulation: **79 groups, 2,074 assertions, zero failures**. New coverage verifies all four opening objectives from physical world state and their handoff to the existing campaign. Prior native saves, ownership conservation, connected travel and the entire campaign remain covered.
- Native headless input/layout: **1,674 assertions, zero failures**: 1,549 campaign checks, 61 direct interaction/gesture checks and 64 expedition checks. Real viewport input verifies objective progression plus an exact inventory preview containing source, destination, before/after quantities and moved weight. Phone-landscape inventory and the established crew/cargo layouts remain covered. These are headless checks, not graphical or physical device approval.
- Godot import, simulation, native QA and Android/Windows/Linux exports passed. The initially recovered editor setting still named an expired scratch SDK path; correcting it to the restored pinned SDK allowed the signed Android export. Exported Linux starts headlessly with embedded resources.
- Android **0.70.0 / code 70** uses package `com.hollow.colony.prototype`, minimum API 24 and target API 35. APK Signature Schemes v2/v3 verify with the preserved certificate SHA-256 `df7193174d83fa04c2be605ebcfb4c989c302fc714705674b449d3b60cbdef62`. `tools/verify_android_signing.py` refuses an absent or mismatched key.
- GitHub's initial source import was read back and all 49 source blob identities plus the complete 71-commit recovery bundle matched. The setup commit was retained. Original commits remain in the bundle pending approved attachment to branch history; no GitHub Actions workflow is installed.
- The 0.70 code commit `be3db1c1161bc4baf6454e1a74d0ace8996f14bb` was published as a fast-forward from the reconciled 0.69 checkpoint. Package archive integrity, engine notices, signing-material exclusion, signatures and packaged Linux launch passed before delivery.

Graphical QA was attempted: X11 and Wayland could not initialize; Xvfb is unavailable. `adb devices -l` reports no attached devices. Actual Android/Windows execution, rendering, sound, touch comfort, update installation, performance and battery behavior remain unverified.

No new raster art, audio or third-party dependency is required. The guidance and preview use original code-native controls; existing original asset generators and engine notices remain. This is a prototype, not a store-ready release.

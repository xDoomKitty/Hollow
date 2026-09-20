# Hollow native checkpoint — 0.69.0

Canonical source: https://github.com/xDoomKitty/Hollow. Read AGENTS.md, DIRECTION.md and ROADMAP.md before editing. Preserve the earlier browser Site separately.

Completed: **Crew & Cargo** pauses for expedition planning. The scrollable roster shows each colonist's depth, condition, fatigue, task, pack weight and essential cargo. Find follows the actual colonist; Pack opens their independent inventory. Join depth uses saved physical travel through connected stairs; Rally by walks to the selected colonist on the same floor. Busy, queued, drafted, lost or incapacitated colonists are not redirected. Intermediate gates stop travel with an explanation.

Cargo searches item or owner names, optionally including ordinary supplies and worn equipment. It reports exact physical quantities only from packs and searched, explored containers. Storage can be located on a remembered map; remote map taps cannot issue orders on another floor. Follow returns to the selected colonist. The owner's 0.68 drag scrolling and tap-to-interact controls remain. The campaign ends at Wayfarer Commons, depth 53.

Validation: 78 simulation groups / 2,069 assertions and 1,670 native headless input/layout assertions passed. Godot import, Windows/Linux exports and exported Linux headless launch passed. See VALIDATION.md for coverage. Graphical startup failed (no X11/Wayland/Xvfb), and adb reports no devices; no Android/Windows device execution is claimed.

**Android is blocked, not updated.** The preserved PRIVATE signing bundle repeatedly returned HTTP 502 when downloading. No replacement key was generated and no 0.69 APK was exported. Keep the last-good 0.68.0 / code 68 download unchanged. Source/export settings reserve 0.69.0 / code 69 for the eventual correctly signed update. The new signing preflight refuses absent or mismatched keys.

Next: retry recovery of the original signing key and deliver the Android update, then improve opening-expedition guidance and item-transfer readability before another campaign floor.

## Source continuity

Repository source import commit: b1b23156d79c9cf401c4fa1d4611c1f6abeb7aac. It retains setup commit b8e554c32d560543ea60110ca505b97f15051192. The complete 71-commit native history is stored at `.github/import/Hollow-history.bundle`, head d0bba28036f68a929c4ef7e1679b63f38dda8950. Those historical commits are recoverable but are not yet ancestors of GitHub main.

Automatic approval review blocked installing a persistent GitHub Actions workflow with permission to merge and push to main. **No workflow is installed.** docs/GITHUB_IMPORT_WORKFLOW.md is a review-only proposal. Owner approval is needed before installing or running it. Ordinary source commits can continue; preserve both histories and never force-push.

GitHub now stores current source, tests, docs and original asset generators. The saved 0.68 Hollow_Source.zip remains a historical fallback, not a second live source archive. Keep the private workstation index and working downloads in their existing identities with fresh version guards. The index records the exact published source revision and mixed platform versions. Exclude private signing material and toolchains.

## Recovery and commands

Restore GitHub main, compare any surviving checkout and retain newer work. If direct Git transport is unavailable, authenticated repository file/Git-object tools can restore the exact source; keep the bundled native history. Use the historical source archive only as a fallback and compare it with the latest remote checkpoint before editing. Never restart the project.

`python3 tools/bootstrap.py` restores Godot 4.5.1 and templates (~1.3 GB). `python3 tools/fetch_android_tools.py` restores Android SDK build-tools 35.0.1 and platform tools; Java 17 is required. Engine: `tools/Godot_v4.5.1-stable_linux.x86_64`; SDK: `tools/android-sdk`; Java: `/usr/lib/jvm/java-17-openjdk-amd64`. Configure the matching Godot editor paths without overwriting unrelated settings.

Run `python3 tools/build.py --android` and `python3 tools/run_native_qa.py`. The Android build now validates the existing prototype key before export. Restore it only from PRIVATE Hollow_Test_Signing.zip to `/root/.local/share/godot/keystores/debug.keystore`. Development alias/password: `androiddebugkey` / `android`; private key bytes must never be published. Required certificate SHA-256: `df7193174d83fa04c2be605ebcfb4c989c302fc714705674b449d3b60cbdef62`. Verify the exported APK's signature and manifest before replacing the Android download.

Commit before `python3 tools/package.py OUTPUT_DIRECTORY`. If Android is blocked, build desktops with `python3 tools/build.py` and package with `--skip-android`; its manifest explicitly excludes Android. Do not replace last-good downloads with missing or unverified exports. Packages retain notices, tracked source/tests/assets/generators and full recoverable history. `--visual` QA requires a working display.

Resume the existing development task rather than creating a duplicate automation. Routine development is authorized; spending, new accounts, store submission and messages to others require separate owner action.

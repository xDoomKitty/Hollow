# Hollow native checkpoint — 0.70.0

Canonical source: https://github.com/xDoomKitty/Hollow. Read AGENTS.md, DIRECTION.md and ROADMAP.md before editing. Preserve the earlier browser Site separately.

Completed: **Guided First Expedition** turns the opening into four concrete world-state-backed steps: tap the traveler, tap and search Shelter supplies, move exactly 4 timber plus 2 scrap into one colonist's pack, and build a Workbench. The objective advances only when those physical actions actually happen and adds no new saved fields.

Inventory rows now state exact ownership and unit weight. Selecting a quantity previews the source and destination, both before/after counts, total moved weight, and resulting pack load. The action button names its destination. Goods remain physically owned until the colonist reaches the container. Crew & Cargo, drag scrolling, tap-to-approach interaction, persistent separate packs and the full campaign through Wayfarer Commons remain intact.

Validation: 79 simulation groups / 2,074 assertions and 1,674 native headless input/layout assertions passed. Godot import and Android/Windows/Linux exports passed after correcting the recovered Android SDK setting. See VALIDATION.md for coverage. Graphical startup remains unavailable (no X11/Wayland/Xvfb), and adb reports no devices; no Android/Windows device execution is claimed.

**Android 0.70 is built and verified.** Code 70 retains package `com.hollow.colony.prototype` and certificate SHA-256 `df7193174d83fa04c2be605ebcfb4c989c302fc714705674b449d3b60cbdef62`; v2/v3 signatures verify. No replacement key was generated. The signing preflight still refuses absent or mismatched keys.

Android, Windows and Linux 0.70 packages are staged for their existing download identities with engine notices. The preserved source archive remains the historical 0.68 fallback because GitHub is canonical; do not maintain a second live source archive.

Validated game revision: `be3db1c1161bc4baf6454e1a74d0ace8996f14bb`; later commits update release records only. Delivered 0.70 SHA-256: Android `75d0175065eb30751bd2c2806dd1149963258c1484d5929ac4bc5e90015fb0b6`; Windows `e56a623dba816b1782a4cdb72a030d0a2f78b2a9f36e0ca2a98c26cc594847e7`; Linux `a97102acedfea133037efa0cc20b6a31546dda166c2033e9825378041a0ff5ef`. Archives, notices, signing material exclusion and packaged Linux launch passed. If scratch disappears, rebuild from GitHub; no completed source work exists only in scratch.

Next: extend the Underway road with a new exploration decision that uses the clearer physical-transfer controls.

## Source continuity

Repository source import commit: b1b23156d79c9cf401c4fa1d4611c1f6abeb7aac. It retains setup commit b8e554c32d560543ea60110ca505b97f15051192. The complete 71-commit native history is stored at `.github/import/Hollow-history.bundle`, head d0bba28036f68a929c4ef7e1679b63f38dda8950. Those historical commits are recoverable but are not yet ancestors of GitHub main.

Automatic approval review blocked installing a persistent GitHub Actions workflow with permission to merge and push to main. **No workflow is installed.** docs/GITHUB_IMPORT_WORKFLOW.md is a review-only proposal. Owner approval is needed before installing or running it. Ordinary source commits can continue; preserve both histories and never force-push.

GitHub now stores current source, tests, docs and original asset generators. The saved 0.68 Hollow_Source.zip remains a historical fallback, not a second live source archive. Keep the private workstation index and working downloads in their existing identities with fresh version guards. The index records the exact published source revision and mixed platform versions. Exclude private signing material and toolchains.

## Recovery and commands

Restore GitHub main, compare any surviving checkout and retain newer work. If direct Git transport is unavailable, authenticated repository file/Git-object tools can restore the exact source; keep the bundled native history. Use the historical source archive only as a fallback and compare it with the latest remote checkpoint before editing. Never restart the project.

`python3 tools/bootstrap.py` restores Godot 4.5.1 and templates (~1.3 GB). `python3 tools/fetch_android_tools.py` restores Android SDK build-tools 35.0.1 and platform tools; Java 17 is required. Engine: `tools/Godot_v4.5.1-stable_linux.x86_64`; SDK: `tools/android-sdk`; Java: `/usr/lib/jvm/java-17-openjdk-amd64`. Configure the matching Godot editor paths without overwriting unrelated settings.

Run `python3 tools/build.py --android` and `python3 tools/run_native_qa.py`. The Android build validates the existing prototype key before export. Restore signing only through the private workstation continuity record; do not publish key paths, credentials or private key bytes. Required public certificate SHA-256: `df7193174d83fa04c2be605ebcfb4c989c302fc714705674b449d3b60cbdef62`. Verify the exported APK's signature and manifest before replacing the Android download.

Commit before `python3 tools/package.py OUTPUT_DIRECTORY`. If Android is blocked, build desktops with `python3 tools/build.py` and package with `--skip-android`; its manifest explicitly excludes Android. Do not replace last-good downloads with missing or unverified exports. Packages retain notices, tracked source/tests/assets/generators and full recoverable history. `--visual` QA requires a working display.

Resume the existing development task rather than creating a duplicate automation. Routine development is authorized; spending, new accounts, store submission and messages to others require separate owner action.

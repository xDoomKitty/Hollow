# Hollow native checkpoint — 0.71.0

Canonical source: https://github.com/xDoomKitty/Hollow. Read AGENTS.md, DIRECTION.md and ROADMAP.md before editing. Preserve the earlier browser Site separately.

Completed: **Underway Fork** at depth 54 carries Wayfarer history into resident, hidden or public approaches. Present the physical convoy tally, clear one burrower, one Gloam stalker or two husks, recover a 2 kg survey kit, and choose a lit bridge or shrouded bypass. The lit route consumes the kit with exactly 3 scrap and 2 glowstone, grants recovery and stores, and visibly draws two husks. The hidden route consumes the kit with exactly 2 timber and 3 rations, grants strong pressure shelter and creates no new incursion. Completion preserves the tally, issues one physical route token and opens the connected deeper road.

Physical cargo stays in its carrier's pack until work completes; cancellation consumes nothing. Threats, lighting, custody, exact quantities, benefits, topology, active work and older visited floors persist. Crew & Cargo, guided opening, drag scrolling, tap-to-approach interaction, exact transfer previews and the prior campaign remain intact.

Validation: 80 simulation groups / 2,148 assertions and 1,704 native headless input/layout assertions passed. Godot import and Android/Windows/Linux exports passed. See VALIDATION.md for coverage. Graphical startup remains unavailable, and adb reports no devices; no Android/Windows device execution is claimed.

**Android 0.71 is built and verified.** Code 71 retains package `com.hollow.colony.prototype` and certificate SHA-256 `df7193174d83fa04c2be605ebcfb4c989c302fc714705674b449d3b60cbdef62`; v2/v3 signatures verify. No replacement key was generated. The signing preflight still refuses absent or mismatched keys.

Android, Windows and Linux 0.71 packages are prepared for their existing download identities with engine notices. The preserved source archive remains the historical 0.68 fallback because GitHub is canonical; do not maintain a second live source archive.

Validated game revision: `3444f41616848fda3d7fd7234471dfac1ff22626`; later commits update release records only. Delivered 0.71 SHA-256: Android `a4912a4ee68e2712b6d9d2d7c427946f79e85f04933f6ccbe23ae2f367cb6329`; Windows `2d7461d7ac567a1650a6ae30f65e1268f4181d34dddda9ce5cd802972340789d`; Linux `ae2a2e2719bf2e4a7339143877420e85529c5c2e6630d1c8a4f654bcf6ce97f8`. Archives, notices, private-key exclusion, signatures and packaged Linux launch passed. If scratch disappears, rebuild from GitHub; no completed source work exists only in scratch.

Next: build **Underway Exchange**, where the route token changes settlement reception and a physical navigation-table repair.

## Source continuity

Repository source import commit: b1b23156d79c9cf401c4fa1d4611c1f6abeb7aac. It retains setup commit b8e554c32d560543ea60110ca505b97f15051192. The complete 71-commit native history is stored at `.github/import/Hollow-history.bundle`, head d0bba28036f68a929c4ef7e1679b63f38dda8950. Those historical commits are recoverable but are not yet ancestors of GitHub main.

Automatic approval review blocked installing a persistent GitHub Actions workflow with permission to merge and push to main. **No workflow is installed.** docs/GITHUB_IMPORT_WORKFLOW.md is a review-only proposal. Owner approval is needed before installing or running it. Ordinary source commits can continue; preserve both histories and never force-push.

GitHub stores current source, tests, docs and original asset generators. The saved 0.68 Hollow_Source.zip remains a historical fallback, not a second live source archive. Keep the private workstation index and working downloads in their existing identities with fresh version guards. The index records the exact published source revision and platform versions. Exclude private signing material and toolchains.

## Recovery and commands

Restore GitHub main, compare any surviving checkout and retain newer work. If direct Git transport is unavailable, authenticated repository file/Git-object tools can restore the exact source; keep the bundled native history. Use the historical source archive only as a fallback and compare it with the latest remote checkpoint before editing. Never restart the project.

`python3 tools/bootstrap.py` restores Godot 4.5.1 and templates (~1.3 GB). `python3 tools/fetch_android_tools.py` restores Android SDK build-tools 35.0.1 and platform tools; Java 17 is required. Engine: `tools/Godot_v4.5.1-stable_linux.x86_64`; SDK: `tools/android-sdk`; Java: `/usr/lib/jvm/java-17-openjdk-amd64`. Configure the matching Godot editor paths without overwriting unrelated settings.

Run `python3 tools/build.py --android` and `python3 tools/run_native_qa.py`. The Android build validates the existing prototype key before export. Restore signing only through the private workstation continuity record; do not publish key paths, credentials or private key bytes. Required public certificate SHA-256: `df7193174d83fa04c2be605ebcfb4c989c302fc714705674b449d3b60cbdef62`. Verify the exported APK's signature and manifest before replacing the Android download.

Commit before `python3 tools/package.py OUTPUT_DIRECTORY`. If Android is blocked, build desktops with `python3 tools/build.py` and package with `--skip-android`; its manifest explicitly excludes Android. Do not replace last-good downloads with missing or unverified exports. Packages retain notices, tracked source/tests/assets/generators and full recoverable history. `--visual` QA requires a working display.

Resume the existing development task rather than creating a duplicate automation. Routine development is authorized; spending, new accounts, store submission and messages to others require separate owner action.

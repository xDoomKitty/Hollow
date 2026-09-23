# Hollow 0.73 source recovery

The tested 0.73 release is fully preserved in `.github/import/Hollow-0.73-update.bundle`. Its exact source commit is `79dbe33f067567fb0d3513d00d9a4cd431100e3c` on bundled ref `refs/heads/hollow-073-release`. The bundle includes the completed 0.72 source, the 0.73 contract-supply checklist, and the merge retaining the prior remote recovery checkpoint.

**Ordinary source-file synchronization is still pending.** Outside the recovery files, GitHub main still shows 0.71 source. A full upload of the 773 KB `world.gd` file stalled; direct Git push has no transport credentials in the current environment. Do not build the ordinary main tree as 0.73 or overwrite the recovered release with those older files. This bundle preserves the exact completed source without requiring a privileged workflow or changing repository access controls.

## Restore the tested release

From a normal clone of this repository:

```sh
git fetch origin main
git switch main
git pull --ff-only origin main
git bundle verify .github/import/Hollow-0.73-update.bundle
git fetch .github/import/Hollow-0.73-update.bundle refs/heads/hollow-073-release:refs/heads/hollow-073-recovery
git switch hollow-073-recovery
git rev-parse HEAD
```

The final command must print `79dbe33f067567fb0d3513d00d9a4cd431100e3c`. The incremental bundle requires ancestor `9780ae6f981789dcace16b0ac6605c65c764399a`, which remains in main history. Preserve newer local work before switching an existing checkout. Read `AGENTS.md`, `docs/DIRECTION.md`, `docs/ROADMAP.md`, and `docs/CHECKPOINT.md` from the recovered release before editing. Reconcile future remote changes without force-pushing.

The tested release passed 2,365 simulation assertions and 1,831 native headless input/layout assertions. Android version code is 73 and preserves the existing prototype signing certificate. Physical Android/Windows gameplay and graphical-device testing remain unverified. Download hashes and the final package revision are recorded in the private workstation index and build manifest.

The earlier 0.72 recovery bundle and original native history bundle remain preserved. Private signing material is excluded from source and game downloads. Current source belongs in this repository; the saved 0.68 source archive remains a historical fallback.

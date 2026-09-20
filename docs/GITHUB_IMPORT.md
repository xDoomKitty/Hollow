# Hollow source import

The native Godot 4.5.1 project is stored in this repository. Initial import commit `b1b23156d79c9cf401c4fa1d4611c1f6abeb7aac` matched native source revision `d0bba28036f68a929c4ef7e1679b63f38dda8950`, whose 0.68 game code matches `7c3d1f25b40f61b30f46659fbb314f34adb19902`. Current development continues from that verified snapshot, including the 0.69 Crew & Cargo overview.

## History preservation

All 71 original native commits are preserved in `.github/import/Hollow-history.bundle`. Bundle SHA-256: `b984f23f201a43019054cc4e501b54903f3ab139823673871f7eab98e8160113`. The bundle contains the complete native history; cloning its `main` branch restores the original commit identities. The initial source import verified 49 tracked files. Historical files and current files were checked for private signing material before upload.

The repository's initial setup commit, `b8e554c32d560543ea60110ca505b97f15051192`, is retained. The native commits are currently recoverable from the bundle, but have **not yet been attached to this repository's branch history**.

## Pending history attachment

Automatic approval review rejected installing a persistent GitHub Actions workflow with permission to merge and push to `main`. No such workflow was installed. [The exact proposed workflow](GITHUB_IMPORT_WORKFLOW.md) is saved as a review-only document. Running it requires separate owner approval. Ordinary source development and commits can continue without it; any later source changes must be reconciled before that import job is approved or executed.

Android remains version 0.68.0 because recovery of the preserved signing key is temporarily blocked. Windows and Linux have 0.69 exports; consult the current checkpoint for delivery status. Private signing keys and the private workstation index are excluded from this repository.

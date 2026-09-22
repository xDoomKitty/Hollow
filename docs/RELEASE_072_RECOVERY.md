# Hollow 0.72 recovery checkpoint

The playable 0.72 source is committed as 92a874a54f71a10acfac7eb055f93bbe82cdec59 and preserved in `.github/import/Hollow-0.72-update.bundle`. Large-file source synchronization was interrupted; the ordinary main source files still describe 0.71. Do not discard a newer local checkout in favor of those files.

The bundle requires existing commit 9780ae6f981789dcace16b0ac6605c65c764399a. From this repository, verify the bundle and fetch its `refs/heads/main` into a new recovery branch, then reconcile the main checkpoint commit without force-pushing. The bundle contains the exact completed source, tests, original map art and docs. The original native history bundle is unchanged.

0.72 adds Underway Exchange, fixes unreachable Underway lit stores/husks, avoids migrated object collisions and fixes deep procedural enemy placement. Verification: 82 simulation groups / 2314 assertions; 1746 native input/layout assertions; all exports; original Android certificate/code72; archive integrity/notices/private-key exclusion/recoverable source history/packaged Linux headless launch. Physical Android and graphical checks remain unverified.

Current downloads and their hashes are recorded in the private Hollow workstation index. Finish ordinary source synchronization before the next feature. No privileged workflow has been added.

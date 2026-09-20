# Proposed one-time history attachment

**Review only: this Markdown document does not install or run a workflow.**

The source is already in this repository and now has newer gameplay changes. All 71 earlier native commits are preserved in the bundled history. This proposal attaches their original identities to GitHub's branch graph without replacing any current game files.

Automatic approval review rejected installing the earlier job because a persistent workflow would have permission to push to main. Owner approval is required before this proposal is installed as `.github/workflows/import-history.yml` or executed.

The job uses a standard Ubuntu runner and the repository's temporary GitHub token with **contents: write**. On installation it runs only for this repository's main branch. It verifies the bundle hash, head, commit count and historical tree; creates an ancestry merge using the `ours` strategy to retain current source; verifies every current file; removes the temporary bundle from the current tree; updates the import report; and makes one non-forced push. Newer remote changes cause the push to fail rather than be overwritten.

The workflow remains after success, but later runs exit without changes when the bundle is absent. Private signing material is never used. Approval grants the proposed job permission to modify main; ordinary source development does not require this job.

```yaml
name: Import Hollow native history

on:
  push:
    branches: [main]
    paths: ['.github/import/Hollow-history.bundle', '.github/workflows/import-history.yml']
  workflow_dispatch:

permissions:
  contents: write

concurrency:
  group: hollow-native-history-import
  cancel-in-progress: false

jobs:
  import:
    if: github.repository == 'xDoomKitty/Hollow' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Check out current repository history
        uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262
        with:
          ref: main
          fetch-depth: 0

      - name: Verify and merge the original native history
        shell: bash
        run: |
          set -euo pipefail
          bundle=.github/import/Hollow-history.bundle
          if [ ! -f "$bundle" ]; then
            echo 'The one-time history import has already completed.'
            exit 0
          fi
          echo 'b984f23f201a43019054cc4e501b54903f3ab139823673871f7eab98e8160113  .github/import/Hollow-history.bundle' | sha256sum --check --strict
          git bundle verify "$bundle"
          git fetch "$bundle" refs/heads/main:refs/remotes/hollow-import/main
          source_revision=d0bba28036f68a929c4ef7e1679b63f38dda8950
          test "$(git rev-parse refs/remotes/hollow-import/main)" = "$source_revision"
          test "$(git rev-list --count "$source_revision")" = 71
          test "$(git rev-parse "$source_revision^{tree}")" = b8f8b8484fc5e7f21b596f84567684dc8ab4a01b
          git config user.name 'Hollow Import'
          git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
          snapshot_revision="$(git rev-parse HEAD)"
          export HOLLOW_IMPORT_SNAPSHOT="$snapshot_revision"
          # The tested source is already imported and has newer gameplay changes.
          # Attach ancestry while retaining the complete current source tree.
          git merge -s ours --no-commit --no-ff --allow-unrelated-histories "$source_revision"
          git diff --cached --exit-code "$snapshot_revision"
          git rm -- "$bundle"
          python3 - <<'PY'
          from pathlib import Path
          import os
          import subprocess
          source = 'd0bba28036f68a929c4ef7e1679b63f38dda8950'
          entries = subprocess.check_output(['git', 'ls-tree', '-rz', os.environ['HOLLOW_IMPORT_SNAPSHOT']]).split(b'\0')
          checked = 0
          for entry in entries:
              if not entry:
                  continue
              meta, name = entry.split(b'\t', 1)
              mode, kind, sha = meta.split()
              if name == b'.github/import/Hollow-history.bundle':
                  continue
              if kind != b'blob':
                  raise SystemExit('Unexpected non-file source entry')
              actual = subprocess.check_output(['git', 'hash-object', '--', name.decode()]).strip()
              if actual != sha:
                  raise SystemExit('Current source changed during ancestry attachment: ' + name.decode())
              checked += 1
          Path('docs/GITHUB_IMPORT.md').write_text(
              '# Hollow repository import\n\n'
              'The original native Godot project and all 71 pre-import commits are preserved in this repository.\n\n'
              '- Historical source revision: `' + source + '`.\n'
              '- Preserved current source revision: `' + os.environ['HOLLOW_IMPORT_SNAPSHOT'] + '`.\n'
              '- Imported source tree: `b8f8b8484fc5e7f21b596f84567684dc8ab4a01b`.\n'
              '- Delivered 0.68 game revision: `7c3d1f25b40f61b30f46659fbb314f34adb19902`.\n'
              '- Original GitHub setup commit: `b8e554c32d560543ea60110ca505b97f15051192`.\n'
              '- Verified ' + str(checked) + ' current files against their pre-merge Git blob hashes before committing the merge.\n\n'
              'Import used an ours-strategy ancestry merge without force-pushing, retaining the current source, both histories and original commit IDs. '
              'The temporary transfer bundle was removed from the current tree. '
              'Private signing keys, toolchains, build caches and the private workstation index were excluded.\n\n'
              'Continue from this repository. See AGENTS.md and docs/CHECKPOINT.md for recovery and validation instructions.\n',
              encoding='utf-8')
          print(f'Verified {checked} current files against the pre-merge tree.')
          PY
          git add docs/GITHUB_IMPORT.md
          git commit -m 'Attach complete native history while preserving current source'
          git merge-base --is-ancestor b8e554c32d560543ea60110ca505b97f15051192 HEAD
          git merge-base --is-ancestor "$source_revision" HEAD
          git fsck --full
          git push origin HEAD:refs/heads/main
          echo 'Full native source history import completed.'
```

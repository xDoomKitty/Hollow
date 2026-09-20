# Proposed one-time history import

Status: awaiting owner approval. This document is a review copy; it does not install or run a workflow.

The current repository contains the native source snapshot and the complete 71-commit recovery bundle. The job below would attach those original commits to the repository graph by merging them into main, verify every original source file, remove the temporary transfer bundle from the current tree, and push one merge commit. It uses the repository's short-lived GITHUB_TOKEN with contents:write. It has a ten-minute limit, accepts no external input, and does not use or upload signing keys. It never force-pushes. The workflow remains in the repository after completion; later invocations exit without mutation when the bundle is absent.

Automatic approval review rejected installing this job because of its ability to push directly to main. Do not install or run it until the owner explicitly approves this one-time job. Normal source updates remain authorized.

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
          git merge --no-commit --no-ff --allow-unrelated-histories "$source_revision"
          git diff --cached --exit-code "$source_revision" -- . ':(exclude).github/import/Hollow-history.bundle' ':(exclude).github/workflows/import-history.yml' ':(exclude)docs/GITHUB_IMPORT.md' ':(exclude)docs/GITHUB_IMPORT_WORKFLOW.md'
          git rm -- "$bundle"
          python3 - <<'PY'
          from pathlib import Path
          import subprocess
          source = 'd0bba28036f68a929c4ef7e1679b63f38dda8950'
          entries = subprocess.check_output(['git', 'ls-tree', '-rz', source]).split(b'\0')
          checked = 0
          for entry in entries:
              if not entry:
                  continue
              meta, name = entry.split(b'\t', 1)
              mode, kind, sha = meta.split()
              if kind != b'blob':
                  raise SystemExit('Unexpected non-file source entry')
              actual = subprocess.check_output(['git', 'hash-object', '--', name.decode()]).strip()
              if actual != sha:
                  raise SystemExit('Imported source differs: ' + name.decode())
              checked += 1
          Path('docs/GITHUB_IMPORT.md').write_text(
              '# Hollow repository import\n\n'
              'The original native Godot project and all 71 pre-import commits are preserved in this repository.\n\n'
              '- Imported source revision: `' + source + '`.\n'
              '- Imported source tree: `b8f8b8484fc5e7f21b596f84567684dc8ab4a01b`.\n'
              '- Delivered 0.68 game revision: `7c3d1f25b40f61b30f46659fbb314f34adb19902`.\n'
              '- Original GitHub setup commit: `b8e554c32d560543ea60110ca505b97f15051192`.\n'
              '- Verified ' + str(checked) + ' source files against their original Git blob hashes before committing the merge.\n\n'
              'Import used a non-forced merge, retaining both histories and the original commit IDs. '
              'The temporary transfer bundle was removed from the current tree. '
              'Private signing keys, toolchains, build caches and the private workstation index were excluded.\n\n'
              'Continue from this repository. See AGENTS.md and docs/CHECKPOINT.md for recovery and validation instructions.\n',
              encoding='utf-8')
          print(f'Verified {checked} source files against the original tree.')
          PY
          git add docs/GITHUB_IMPORT.md
          git commit -m 'Import Hollow 0.68 source with complete native history'
          git merge-base --is-ancestor b8e554c32d560543ea60110ca505b97f15051192 HEAD
          git merge-base --is-ancestor "$source_revision" HEAD
          git fsck --full
          git push origin HEAD:refs/heads/main
          echo 'Full native source history import completed.'
```

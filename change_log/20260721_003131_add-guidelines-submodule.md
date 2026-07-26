# Change log — Add Flutter Guidelines submodule

Implements plan: `plans/20260721_003131_add-guidelines-submodule.md`

## What was changed

1. **Initialized a Git repository** in the project root (`git init -b main`). The folder was not
   a repo before, so this was required to add a submodule.
2. **Added the guidelines submodule** at `docs/guidelines/`:
   - URL: `https://github.com/sreerajp80/Flutter_Guidelines`
   - Command: `git submodule add https://github.com/sreerajp80/Flutter_Guidelines docs/guidelines`
   - This created `.gitmodules` and checked out the guideline documents referenced by
     `docs/GUIDELINES_MANIFEST.md` (guideline.md, flutter_project_engineering_standard.md,
     architecture.md, release_process.md, security.md, and more).
3. **Made the initial commit** (`bdcef03`) recording `.gitmodules`, the submodule pointer, and the
   existing `docs/` files.

## Notes

- Default branch is `main` (as approved).
- The submodule is pinned to commit `d014cc8` on the guidelines repo's `master` branch.
- Git reported LF→CRLF line-ending warnings on Windows; these are harmless.
- No remote was configured for this project repo (none was requested). To push later, add a
  remote and run `git push -u origin main`.

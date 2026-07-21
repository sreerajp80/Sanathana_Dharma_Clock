# Add Flutter Guidelines as a Git submodule

**Status:** in_progress

## What the issue is

- The app folder `Sanathana_Dharma_Clock` has `docs/GUIDELINES_MANIFEST.md`, which says to add
  the shared Flutter guidelines repository as a Git submodule at `docs/guidelines/`.
- The submodule cannot be added yet because this folder is **not a Git repository** (no `.git`,
  no `.gitmodules`).
- Submodule URL provided by the user: `https://github.com/sreerajp80/Flutter_Guidelines`

## Files / things to be changed

- Create `.git/` (by running `git init`) — new local Git repository.
- Create `.gitmodules` — records the submodule mapping.
- Create `docs/guidelines/` — the checked-out submodule content.
- Create an initial commit (needed so the submodule add is recorded).

## The plan for the fix

1. Run `git init` in the project root to make it a Git repository.
2. Add the submodule:
   `git submodule add https://github.com/sreerajp80/Flutter_Guidelines docs/guidelines`
3. Verify: confirm `.gitmodules` points to the correct URL and path, and that
   `docs/guidelines/` now contains the guideline documents referenced in the manifest.
4. Make an initial commit recording `.gitmodules`, the submodule pointer, and the existing
   `docs/` files.

## Open questions

- Confirm you want me to `git init` this folder (it is not yet a repo).
- Confirm the default branch name (`main`) is fine.

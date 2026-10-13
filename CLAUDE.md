# phazite-sounds

Phazite Sounds, the free sound pack that Phazite (https://github.com/august-byrne/Phazite) downloads: CC0 sounds, the recipes they are made from, and the scripts around them. README.md explains the layout, the recipe format, and how to make, check and release the pack.

- Only CC0 1.0 sounds go in the pack, each listed in `pack/sources.json` with its sources (README.md, "Adding or changing sounds"). After changing the pack, run `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check-pack.ps1`.
- `pack/`'s sounds and `sources.json` are rendered by `phazite_soundkit` (in Phazite's repository, `tools/soundkit`) from `recipes.json`; never edit them by hand. `pack/README.txt` and `pack/LICENSE.txt` are written by hand.
- Never replace a released zip: Phazite pins each release's SHA-256. Release a new version instead (README.md, "Releasing a version").
- The repository is public, and nothing confidential may reach it. Read `git diff --cached` in full before every commit. Commit emails must be GitHub noreply addresses; the hooks in `.githooks` (turned on with `git config core.hooksPath .githooks`) check emails, file sizes, whitespace and secrets. Never skip them with `--no-verify`. Stage a new or changed hook with `git add --chmod=+x .githooks/<name>`.
- Write commit messages to a file and use `git commit -F <file>`. Never add a remote or push unless asked.

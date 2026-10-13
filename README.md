# Phazite Sounds

Free sounds for [Phazite](https://github.com/august-byrne/Phazite), the open-source DAW: 85 drums, 808s, loops, effects and foley sounds, about 9 MB of 44.1 kHz FLAC. Phazite offers to download them the first time it opens. Later, they are in **Help > Phazite Sounds**, and in the browser's **Phazite Sounds** folder. Without a connection, download the zip from [Releases](https://github.com/august-byrne/phazite-sounds/releases) on another computer, and install it in Phazite with **Install from a File...** in that same window.

## Use them in anything

Every sound is dedicated to the public domain under [CC0 1.0 Universal](LICENSE.txt). You can use them in any song, sell what you make with them, and change them, without asking or giving credit.

They are separate from Phazite's code, which is under the AGPL-3.0-or-later, and are downloaded separately. The AGPL's terms don't extend to them, or to what you make with them.

## Where they come from

The pack holds CC0 sounds only, from two kinds of source.

**Sample libraries that dedicate their sounds to CC0:**
- the [Versilian Community Sample Library](https://github.com/sgossner/VCSL) and [Virtuosity Drums](https://github.com/sfzinstruments/virtuosity_drums), by Versilian Studios;
- [Big Rusty Drums](https://github.com/sfzinstruments/karoryfer.big-rusty-drums), by Karoryfer Samples;
- [body_percussion](https://github.com/sfzinstruments/body_percussion), from sfzinstruments;
- [FreePats Synthesizer Percussion](https://github.com/freepats/synthesizer-percussion), by Roberto, made with the Yoshimi and Geonkick synthesizers;
- [Sonic Pi](https://github.com/sonic-pi-net/sonic-pi)'s samples, from Freesound users soneproject, Halgrimm, EcoDTR and maqsim;
- a [breakbeat](https://archive.org/details/108_bpm_breakbeat_to_use) that EatMe recorded and put in the public domain;
- [RPG Audio](https://kenney.nl/assets/rpg-audio) and [Impact Sounds](https://kenney.nl/assets/impact-sounds), by Kenney.

Credit isn't required, but they deserve it.

**Phazite's own:** kicks, 808s, analog-style drums and effects that Phazite's `phazite_soundkit` synthesizes, and loops it plays from these sounds, to patterns written for Phazite. Their contributors dedicate them to the public domain under CC0 1.0.

[pack/sources.json](pack/sources.json) records how each sound was made. For a sound taken from a library, it gives the library's title and author, a link to the file at the commit it was taken from, what says it is CC0, the downloaded file's SHA-256, and what was done to it.

## What is here

- `recipes.json`: how each sound is made (see [Recipes](#recipes)).
- `pack/`: the pack as it ships. `phazite_soundkit` writes the sounds and `sources.json`; `README.txt` and `LICENSE.txt` are written by hand.
- `tools/download-sources.sh`: downloads the sounds the recipes take, from the pinned commits and files.
- `tools/check-pack.ps1`: checks that every sound in `pack/` is listed in `sources.json` as CC0, with its sources. CI runs it on every push.

Everything in this repository is CC0 1.0: the sounds, the recipes and the scripts.

## Making the pack

`phazite_soundkit` is part of Phazite's source (`tools/soundkit`), because it uses Phazite's build of JUCE.

1. In a clone of Phazite, build it: `cmake --preset windows-debug`, then `cmake --build --preset windows-debug --target phazite_soundkit`. It is then at `build/windows-debug/phazite_soundkit_artefacts/Debug/`.
2. Here, download the sources: `sh tools/download-sources.sh <an empty folder outside this repository>` (needs curl and unzip, which Git Bash has).
3. Render the pack: `phazite_soundkit recipes.json <that folder> pack`. It writes every sound and `pack/sources.json`, and names any sound file in `pack/` that the recipes no longer make, for you to delete.
4. `phazite_soundkit --info pack` prints each sound's length, channels, peak and RMS level, and spectral centroid. Listen to every sound you changed.
5. Check the pack: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check-pack.ps1` on Windows, or `pwsh tools/check-pack.ps1`.

The same recipe always makes the same file: every random choice, the dither included, is seeded, and the dither's seed comes from the sound's path, so adding or moving other sounds changes nothing else. Phazite's `windows-debug` and `windows-release` builds render the same files. Another compiler's maths library (GCC's, on Linux) can change the last bit of some samples, which no one can hear but which changes the files.

## Recipes

`recipes.json` has four parts.

- **`pack`**: the pack's `name`, its `version` and its `date` (`2026-10-13`), which the zip gives every file.
- **`collections`**: the sample libraries sounds are taken from, by a short name. Each has a `title`, an `author`, a `url` (where its files are, pinned to a commit; a sound's path there is added to it) and `licenceEvidence` (what says the files are CC0).
- **`sounds`**: the one-shots. Each has a `file`, its path in the pack, and either:
  - `take`: the sounds it is taken from, each with its `collection`, its `path` there, its `local` path in the downloaded sources, and an optional `note`. Several takes are mixed, each later one at half the level.
  - or `synth`, a sound `phazite_soundkit` makes (types below), and a `description` of it for `sources.json`.

  Every one-shot can have a `shape`: `maxSeconds` (default 0: as long as it rings, down to -60 dB), `fadeOutSeconds` (0.01), `keepLength` (false: it is trimmed from its first sound to where it fades under -60 dB) and `reverse` (false). Every sound is normalized to -1 dBFS.
- **`loops`**: each has a `file`, a `bpm` and a whole number of `bars`, and either:
  - `take`: a recorded loop, cut to exactly its bars, with an optional `shape`;
  - or `lines` played from the one-shots, with an optional `swing` (how late every other 16th note comes, in 16th notes). A line has a `sound` (a one-shot's `file`), its `hits`, a `level`, and an optional `chokeGroup`: hits in the same group cut each other off, as open and closed hats do. `hits` has a 16th note for every step of every bar: `X` accented, `x` a hit, `o` a ghost note, `r` two 32nd notes, `.` nothing.

The synth types, and the numbers each takes:

| `type` | Numbers |
|---|---|
| `kick` | `startHz` and `endHz` (its pitch falls from one to the other), `pitchSeconds`, `decaySeconds`, `seconds`, `click`, `drive`. Kicks and 808s. |
| `snare`, `clap`, `cowbell` | None: 808-style drums. |
| `hat` | `decaySeconds`, `seconds`. |
| `sine` | `hz`, `seconds`. A sub bass. |
| `sweep` | `bars` and `bpm` (its length), `fromHz` and `toHz` (its low-pass), `resonance`, `toneFromHz` and `toneToHz` (a sine under it), and a `level` of `rise`, `fall` or `swell`. |
| `impact` | `fromHz`, `toHz`, `decaySeconds`, `seconds`, `brightness` (its noise burst's low-pass, in Hz). |

`phazite_soundkit` stops at a name it doesn't know, so a misspelt one can't go unnoticed.

## Adding or changing sounds

Only CC0 sounds go in the pack. A third-party sound qualifies when its licence file or source page says CC0 and its description shows no material from anyone else. That rules out sampled records (the Amen break), drum machines' built-in recorded sounds (such as the TR-909's cymbals) and presets of commercial instruments. Synthesized imitations of drum machines are fine; names like "808" describe a style, but never use a maker's name.

Other licences don't qualify:
- CC BY and CC BY-SA: their conditions would follow the sounds into every song made with them.
- GPL, NC and ND licences.
- "Royalty-free" sample licences, which forbid passing the sounds on.

To add a sound, add its collection (pinned to a commit) and its recipe to `recipes.json`, and its download to `tools/download-sources.sh`. Name it by what it is first ("Kick Punchy"). A loop's name says its tempo ("House 124 BPM"), and the loop lasts whole bars at that tempo, so that it previews and plays in time. Then make the pack again (above) and commit the recipe, the script and the pack together.

## Releasing a version

Phazite downloads one version of the pack, pinned by its address, size and SHA-256.

1. Raise `version` and set `date` in `recipes.json`, render the pack and commit.
2. Zip it: `phazite_soundkit --zip pack Phazite-Sounds-<version>.zip`. It prints the zip's size and SHA-256. The same pack always makes the same zip.
3. Tag the commit `v<version>`, and publish a GitHub release of that tag with the zip attached. Never replace a released zip: the Phazite versions that pin it would refuse it.
4. In Phazite, pin the new zip's address, size and SHA-256 in `src/model/SoundPack.cpp`.

## Committing

The repository is public, and a commit stays in its history even after a later one deletes a file. Turn on the git hooks once per clone with `git config core.hooksPath .githooks`. They need [gitleaks](https://github.com/gitleaks/gitleaks) 8.19 or newer (Phazite's `tools\setup-windows.cmd` installs it on Windows). Before every commit and push they check that the commit email is a GitHub noreply address, that no file is larger than 5 MiB, that there is no trailing whitespace or leftover conflict marker, and that gitleaks finds no secrets.

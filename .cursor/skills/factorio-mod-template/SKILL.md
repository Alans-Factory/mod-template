---
name: factorio-mod-template
description: >-
  Guides onboarding for a mod created from the Factorio mod-template: file
  layout, how to obtain and register the mod portal API key, and how to
  prepare a release. Use when the user clones or renames this template, asks
  about the mod layout or the portal key, or asks to publish or prepare a
  version before publishing.
---

# Mod template

The example mod prints a message when the player joins a game. The rest of the repository is the base for tests, packaging, and upload to the portal.

## Mod layout

| File | Role |
|---|---|
| `info.json` | Internal name, version, title, author, `factorio_version`, and description. Required. |
| `control.lua` | Runtime script. In the template, prints `mod-template.hello` on `on_player_joined_game`. |
| `data.lua` | Prototypes, via `data:extend`. Empty until there are prototypes. |
| `changelog.txt` | History shown in the mod browser. The top version is the newest and must match `info.json`. |
| `locale/<language>/*.cfg` | Translations. The language folder is the language code (`en`). |
| `thumbnail.png` | 144×144 image for the mod browser and the portal. |
| `.modfiles` | Globs, from the repository root, of files that go into the zip. `#` comments out the line. A pattern with no match fails packaging. |
| `tests/` | Unit tests that run outside the game. `bash .github/scripts/run-tests.sh` (Lua 5.4). |
| `.github/workflows/test.yml` | Runs the tests on pull requests and on pushes outside `main`. |
| `.github/workflows/publish.yml` | On `main`, runs the tests and then publishes. |
| `.github/scripts/` | Reads `info.json`, builds the zip, uploads it, and runs the tests. |

The game also loads these files when they exist: `settings.lua`, `settings-updates.lua`, `settings-final-fixes.lua`, `data-updates.lua`, and `data-final-fixes.lua`. When creating one of them, add its name to `.modfiles`. Any other `.lua` file runs only if one of these files `require`s it.

When renaming the mod, change the internal name in `info.json`, in the locale file and its section, and in the key used in `control.lua`. The folder inside `mods/` must be the internal name, or `name_version`.

`changelog.txt` starts with a line of exactly 99 dashes. Each version has `Version: ` and, optionally, `Date: `. A category starts with two spaces and ends with a colon. Each entry starts with four spaces, a hyphen, and a space. No tabs and no trailing space. Categories recognized by the game: Major Features, Features, Minor Features, Graphics, Sounds, Optimizations, Balancing, Combat Balancing, Circuit Network, Changes, Bugfixes, Modding, Scripting, Gui, Control, Translation, Debug, Ease of use, Info, Locale, Compatibility.

## Factorio mod portal API key

### Obtaining the key

1. Open <https://factorio.com/profile> with the account that publishes the mod.
2. Create a key under **API Keys**.
3. Do not use the legacy token shown on the profile. Publishing uses only the API key.

### Registering the key on GitHub

1. In the mod repository: **Settings → Secrets and variables → Actions**.
2. Create a repository secret.
3. The name is exactly `FACTORIO_API_KEY`.
4. The value is the key. It does not go into git.

The publish workflow reads that secret and sends it as `Authorization: Bearer` to `https://mods.factorio.com/api/v2/mods/releases/init_upload`.

## Publishing the mod

When the user asks to publish, or to prepare a release before publishing, follow the steps below. Do not commit, stage, or publish before this flow finishes.

### 1. Clean tree

The user must commit and/or discard every change first. Continue only when there are no changes, including staged ones.

Check with `git status --porcelain`. Any output, including a new file or a staged line, ends the flow. Say what is still pending and stop. Do not discard, stash, or commit on the user's behalf.

### 2. What changed since the last portal version

Compare everything that changed since the last version published on the mod portal.

- Read `name` and `version` from `info.json`.
- Query `https://mods.factorio.com/api/mods/<name>`.
- If the mod exists, the published version is the highest `releases[].version`, regardless of array order. Find the commit where `info.json` first had that version and compare from that commit to `HEAD`.
- If the portal responds that the mod does not exist, there is no published version. Compare from the first commit.

### 3. Edit the release files

With that result, edit the relevant files (for example `info.json`, the changelog, and so on), but do not stage or commit them. Only edit.

- If the diff has no change a player would notice, do not change the version or the changelog. Say there is no new release and stop.
- If there is, bump `info.json` `version`: patch for a fix, minor for a feature, major for an incompatible change.
- Insert that version at the top of `changelog.txt`, with today's date in the `DD. MM. YYYY` format and only the categories that fit the changes.
- Adjust locale, description, or thumbnail when the diff requires it.
- Do not run `git add` or `git commit`.

### 4. Message and confirmation

At the end, show a commit message with the new version number and what was done. Tell the user they can continue on their own, and ask whether they want the agent to finish the job. Answering "sim" is enough.

The message uses this format:

```
Release <version>: <what changed for the player>.

<why this version exists>
```

Finishing the job, only after a "sim" reply, means: stage the files changed in this preparation, commit with that message, and push `main`. That push starts the publish workflow. Any other reply does not commit and does not push.

# Mod template

Starter repository for a Factorio mod. Clone it, rename the mod, and keep the packaging, tests, and portal upload that already live here.

Loading a game prints a hello message. That is the whole mod.

## Rename the mod

The internal name is `mod-template`. After cloning, change it in every place it appears:

- `info.json`: `name`, `title`, `author`, and `description`
- `locale/en/mod-template.cfg`: rename the file and the `[mod-template]` section to the new internal name
- `control.lua`: the locale key `mod-template.hello` must use the new section name

The folder name in `mods/` must be the internal name, or `internal-name_version`.

## Layout

| Path | Role |
|---|---|
| `info.json` | Identity, version, and Factorio version. Required. |
| `control.lua` | Runtime script. This template prints the hello message. |
| `data.lua` | Prototypes. Empty until you add some. |
| `changelog.txt` | Version history shown in the in-game mod browser. |
| `locale/` | Translations. One folder per language, with `.cfg` files inside. |
| `thumbnail.png` | 144×144 image for the mod browser and the portal. |
| `.modfiles` | Globs of files that go into the release zip. |
| `tests/` | Unit tests that run outside the game. |
| `.github/` | Test and publish workflows, plus the shell scripts they call. |

Factorio also loads these files when they exist: `settings.lua`, `settings-updates.lua`, `settings-final-fixes.lua`, `data-updates.lua`, and `data-final-fixes.lua`. Add the name to `.modfiles` when you create one. Other Lua files load only if a startup file `require`s them.

## Tests

Requires Lua 5.4 (`sudo apt-get install lua5.4`).

```bash
bash .github/scripts/run-tests.sh
```

## Publish

Pushing to `main` runs the tests and, if they pass, uploads the zip to the Factorio mod portal. When `info.json` already has a version that is on the portal, the upload is skipped and the workflow succeeds.

Create an API key at <https://factorio.com/profile> under **API Keys**. Do not use the legacy profile token. In the GitHub repository, add it as an Actions secret named `FACTORIO_API_KEY` (Settings → Secrets and variables → Actions).

The zip contains only paths matched by `.modfiles`. A pattern that matches nothing fails the package step.

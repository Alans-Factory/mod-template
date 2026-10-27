# Mod template

This repository is a template for new Factorio mods. Clone it, rename the mod, and replace the example with your own content. Packaging, tests, and upload to the mod portal are already in place.

Installing the template and joining a game prints a hello message. That message is the whole example, so you can see that the mod loads.

## What is included

- `info.json`, `control.lua`, `data.lua`, `changelog.txt`, locale files, and a thumbnail
- `.modfiles`, the list of paths that go into the release zip
- Unit tests that run outside the game
- A GitHub Actions workflow that tests pull requests and publishes from `main`
- A project skill so an AI assistant can onboard, configure the portal key, and prepare a release

Factorio 2.1 is the version this template targets.

## Ready to use with AI

This template is ready to use with an AI assistant. The skill at `.cursor/skills/factorio-mod-template/SKILL.md` is project guidance the assistant loads when you clone or rename the mod, ask about the file layout or the portal key, or ask to publish or prepare a version.

The skill covers:

- The role of each file, including locale, changelog format, and `.modfiles`
- How to create a Factorio API key and store it as the GitHub Actions secret `FACTORIO_API_KEY`
- How to prepare a release: require a clean git tree, compare the repository with the last version on the mod portal, bump `info.json` and `changelog.txt`, and show a commit message

The assistant does not stage, commit, or push until you confirm. Answering "yes" is the confirmation to finish the release.

## How to start a mod from it

1. Clone the repository and change the internal name in `info.json`, in the locale file and its section, and in the locale key used by `control.lua`.
2. Name the folder inside `mods/` with that internal name, or `internal-name_version`.
3. Replace the hello message with your prototypes and scripts.
4. Create an API key at [factorio.com/profile](https://factorio.com/profile) under **API Keys**. Store it in the GitHub repository as an Actions secret named `FACTORIO_API_KEY`.
5. Push to `main`. The workflow runs the tests and, when they pass, uploads the zip to this portal.

A pattern in `.modfiles` that matches nothing stops the package step, so the zip only contains files you listed.

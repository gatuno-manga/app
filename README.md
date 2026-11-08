# Gatuno

Flutter client for Gatuno Manga.

## Development

The project ships a [Nix](https://nixos.org) flake that provides Flutter, JDK 17,
the Android SDK, `just`, `lefthook` and the `jaoppb/tools` binaries.

```sh
nix develop            # enter the dev shell
just setup             # install git hooks and run flutter pub get
```

With [direnv](https://direnv.net), run `direnv allow` once and the shell loads
automatically (see `.envrc`).

Git hooks (lefthook) call `just` and Flutter, so commit from inside the shell.

Common tasks (run `just` to list them all): `just gen`, `just l10n`,
`just analyze`, `just test`, `just coverage`, `just fmt`, `just fix`.

The Tools workflow only checks labels and milestones: the default CI token
cannot read repository merge settings. Verify those locally with
`just repo-check` (needs a token that can read them).

The flake supports x86_64/aarch64 Linux and macOS, but only x86_64-linux is
tested. iOS builds are not provided by Nix.

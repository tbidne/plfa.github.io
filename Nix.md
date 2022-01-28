<div align="center">


# Nix

[![Cabal CI](https://img.shields.io/github/workflow/status/tbidne/plfa.github.io/cabal/main?label=cabal&logoColor=white)](https://github.com/tbidne/plfa.github.io/actions/workflows/cabal_ci.yaml)

[![Nix CI](https://img.shields.io/github/workflow/status/tbidne/plfa.github.io/nix/main?label=nix&logo=nixos&logoColor=white)](https://github.com/tbidne/plfa.github.io/actions/workflows/nix_ci.yaml)

</div>

We include two ways to grab this project's necessary dependencies via `nix`.

## 1. Nixpkgs

`nix develop` will pull the dependencies from its `nixpkgs` set (see `flake.nix`).

## 2. Cabal

`nix-shell` will pull the dependencies using cabal's constraint solver (see `shell.nix`). We add a `cabal.project.freeze` file for reproducibility. This option is likely not too useful as we have the generally superior `nix develop`, but it is added primarily to document a package set that works.

In either case, running `cabal build` after entering a shell should build the project.

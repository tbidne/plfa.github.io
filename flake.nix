{
  description = "Programming Language Foundations in Agda";
  inputs.flake-compat = {
    url = github:edolstra/flake-compat;
    flake = false;
  };
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  # TODO Flakify:
  #
  # 1. Shell launches w/ correct agda stdlib (see below note)
  # 2. Shell launches w/ necessary nodejs libs installed
  # 3. nix build that does the above
  # 4. nix build .#serve that builds and starts the webserver

  outputs =
    inputs@{ flake-parts
    , self
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { pkgs, ... }:
        let
          haskellDeps = ps: [
            ps.cabal-install
          ];
          compilerVersion = "ghc962";
          ghc = pkgs.haskell.packages.${compilerVersion}.ghcWithPackages haskellDeps;

          otherDeps = [
            # NOTE: For whatever reason, the agda-mode extension does not seem
            # to work without the stdlib directly included here. We attempted
            # to manually work around this by creating a .agda dir and pointing
            # to that here i.e. shellHook = "export AGDA_DIR=.agda", which
            # fixed the "can't find stdlib" error, but then we received a
            # new, vague "internal parse error". The message suggested a
            # possible version mismatch, though who knows.
            #
            # In any case, explicitly using the stdlib from nixpkgs "works"
            # for now. Of course this is not necessarily the same version
            # as the submodule, so care will have to be taken when
            # updating.
            (pkgs.agda.withPackages [ pkgs.agdaPackages.standard-library ])
            pkgs.fswatch
            pkgs.icu
            pkgs.pkg-config # digest uses pkg-config to search for zlib
            pkgs.nodejs-18_x
            pkgs.zlib
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [ ghc ] ++ otherDeps;

            shellHook = ''
              plfa_mk_builder () {
                cabal build --project-file=cabal.project.ghc-9.6.2
              }

              plfa_build () {
                cabal run builder --project-file=cabal.project.ghc-9.6.2 -- build
              }

              plfa_serve () {
                make serve
              }
            '';
          };
        };
      systems = [
        "x86_64-linux"
      ];
    };
}

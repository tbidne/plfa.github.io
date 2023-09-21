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
            # NOTE: Building depends on having the correct stdlib, which is
            # pinned in the submodule. It would be nice if we guarantee the
            # correct version here, rather than using the submodule. The below
            # commented line is here for reference, as it does not work
            # (i.e. the shell launches fine but still uses the submodule).
            #(pkgs.agda.withPackages [ pkgs.agdaPackages.standard-library ])
            pkgs.agda
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
          };
        };
      systems = [
        "x86_64-linux"
      ];
    };
}

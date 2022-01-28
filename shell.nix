let
  utils = import nix/utils.nix;
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${utils.pkgs-hash}.tar.gz") { };

  haskellDeps = ps: with ps; [
    cabal-install
    cabal-plan
  ];

  otherDeps = with pkgs; [
    nixpkgs-fmt
    pkgs.icu
    pkgs.zlib
  ];

  ghc = pkgs.haskell.packages.${utils.compilerVersion}.ghcWithPackages haskellDeps;
in
pkgs.mkShell {
  buildInputs = [ ghc ] ++ otherDeps;
}

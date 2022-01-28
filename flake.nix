{
  description = "Programming Language Foundations in Agda";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs?rev=468c34be50a91340e34598730b1076b44b9f667e";
  outputs =
    { flake-utils
    , nixpkgs
    , self
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      utils = import nix/utils.nix;
      compiler = pkgs.haskell.packages."${utils.compilerVersion}";
      mkPkg = returnShellEnv:
        compiler.developPackage {
          inherit returnShellEnv;
          name = "plfa";
          root = ./.;
          modifier = drv:
            pkgs.haskell.lib.addBuildTools drv (with pkgs.haskellPackages; [
              cabal-install
              pkgs.nixpkgs-fmt
              pkgs.zlib
            ]);
          overrides = final: prev: with pkgs.haskellPackages; with pkgs.haskell.lib; {
            agda = final.callHackage "agda" "2.6.1.3" { };
            commonmark = final.callHackage "commonmark" "0.1.1.4" { };
            commonmark-extensions = final.callHackage "commonmark-extensions" "0.2.0.4" { };
            commonmark-pandoc = final.callHackage "commonmark-pandoc" "0.2.0.1" { };
            cryptonite = final.callHackage "cryptonite" "0.27" { };
            doctemplates = final.callHackage "doctemplates" "0.8.3" { };
            hslua = final.callHackage "hslua" "1.1.2" { };
            hslua-module-text = final.callHackage "hslua-module-text" "0.2.1" { };
            hakyll = final.callHackage "hakyll" "4.13.4.1" { };
            optparse-applicative = final.callHackage "optparse-applicative" "0.15.1.0" { };
            pandoc = final.callHackage "pandoc" "2.10.1" { };
            pandoc-citeproc = final.callHackage "pandoc-citeproc" "0.17.0.2" { };
            pandoc-types = final.callHackage "pandoc-types" "1.21" { };
            skylighting = final.callHackage "skylighting" "0.8.5" { };
            skylighting-core = final.callHackage "skylighting-core" "0.8.5" { };

            # needed because 0.7.1.0 is not in our all-cabal-hashes package set.
            text-icu = final.callHackageDirect
              {
                pkg = "text-icu";
                ver = "0.7.1.0";
                sha256 = "KvP4njMnpfYEpNF8iAWX0dG1GvstXySxa84AN2uGgZg=";
              }
              { };

            # disable all tests
            mkDerivation = args: prev.mkDerivation (args // {
              doCheck = false;
            });
          };
        };
    in
    {
      defaultPackage = mkPkg false;

      devShell = mkPkg true;
    });
}

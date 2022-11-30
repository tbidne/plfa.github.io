{
  description = "Programming Language Foundations in Agda";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem =
        { pkgs, ... }:
        let
          haskellDeps = [
            pkgs.cabal-install
            pkgs.zlib
          ];

          otherDeps = [
            pkgs.fswatch
            pkgs.icu
            pkgs.pkg-config # digest uses pkg-config to search for zlib
            pkgs.nodejs-18_x
          ];

          # According to the README.
          ghc-version = "ghc948";
          compiler = pkgs.haskell.packages."${ghc-version}".override {
            overrides = final: prev: {
              # Override here rather than use the value in nixpkgs so that we
              # ensure we use the right version.
              Agda = final.callHackage "Agda" "2.6.3" { };
            };
          };

          ghc = compiler.ghcWithPackages (p: [ p.Agda ]);
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs =
              haskellDeps
              ++ otherDeps
              ++ [
                ghc
                pkgs.figlet
                pkgs.lolcat
              ];

            shellHook = ''
              mkdir -p .agda
              cwd=$(pwd)

              # copy defaults to .agda
              cp ./data/dotagda/defaults ./.agda/

              # add stdlib and plfa
              read -r -d \'\' libs_str << EOM
              $cwd/standard-library/standard-library.agda-lib
              $cwd/src/plfa.agda-lib
              EOM

              echo -e "$libs_str" > ./.agda/libraries

              # override default ~/.agda to point to our newly created
              # directory
              export AGDA_DIR=.agda

              plfa_mk_builder () {
                cabal build plfa:exe:builder
              }

              plfa_build () {
                cabal run builder -- build
              }

              plfa_serve () {
                make serve
              }

              echo_color () {
                echo -e "  \033[$1m$2\033[0m"
              }

              echo_list_item () {
                echo -e "  - \033[$1m$2\033[0m$3"
              }

              echo_blue_item () {
                echo_list_item "94" "$1" "$2"
              }

              echo_green () {
                echo_color "92" "$1"
              }

              echo_pink_item () {
                echo_list_item "95" "$1" "$2"
              }

              plfa_vers () {
                echo ""
                echo_green "*** Versions ***"
                echo_blue_item "Agda: " "${compiler.Agda.version}"
                echo_blue_item "Cabal: " "${pkgs.cabal-install.version}"
                echo_blue_item "GHC: " "${ghc.version}"
              }

              plfa_cmds () {
                echo ""
                echo_green "*** Commands ***"
                echo_pink_item "plfa_mk_builder: " "Make the builder application"
                echo_pink_item "plfa_build: " "Build plfa"
                echo_pink_item "plfa_serve: " "Serve plfa on localhost"
                echo_pink_item "plfa_cmds: " "List commands"
                echo_pink_item "plfa_vers: " "List versions"
              }

              echo "PLF in Agda" | figlet -c | lolcat
              echo ""
              echo "  Entered a shell for Programming Language Foundations in Agda."
              echo -e "  This shell is suitable for development and following along interactively.\n"
              echo "  This shell creates the .agda directory that ensures agda"
              echo "  can find the libraries it needs to run. This can be ignored by git by"
              echo "  adding it to the .git/info/exclude file."
              plfa_cmds
              plfa_vers
            '';
          };
        };
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    };
}

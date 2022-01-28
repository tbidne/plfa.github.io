{
  compilerVersion = "ghc8104";

  # flake.lock is our source of truth for nixpkgs
  pkgs-hash = (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs.locked.rev;
}

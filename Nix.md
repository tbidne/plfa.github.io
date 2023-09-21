# Nix

A shell with the required dependencies can be launched with either `nix develop` or `nix-shell`.

## Building

Once in a shell, the project can be built with `cabal build --project-file=cabal.project.ghc-9.6.2`, and from there we can build `plfa` with `cabal run builder`. For instance, `cabal run builder --project-file=cabal.project.ghc-9.6.2 -- build` will build `plfa`.

NB: Building depends on having the correct agda and stdlib. This comes from the ./standard-library submodule, so if you receive receive errors running the builder, check that the version is correct. For ghc `9.6`, the stdlib should be `1.7.2`. When running the builder, you should see a line like:

```
Using Agda version 1.7.2
```

## Deploying

Once `plfa` is built, we can deploy it with `make serve`. This will serve `plfa` on `http://127.0.0.1:3000/`.

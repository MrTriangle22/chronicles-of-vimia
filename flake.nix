{
  description = "Dev flake for a Python game with pynvim and pygame";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pythonPkgs = pkgs.python3Packages;
      pyEnv = pythonPkgs.buildEnv.overrideAttrs (old: {
        name = "py-game-env";
        # include the python packages you asked for
        paths = with pythonPkgs; [
          pynvim
          pygame
          setuptools
          wheel
        ];
      });
    in {
      packages.default = pyEnv;

      devShells.default = pkgs.mkShell {
        buildInputs = [
          pyEnv
          pkgs.git
          pkgs.gcc
          pkgs.pkgconfig
          pkgs.sdl2 # pygame runtime deps on some systems
        ];

        # lightweight informative shell hook
        shellHook = ''
          echo "Dev shell: pynvim and pygame available"
          echo "Test: python -c 'import pynvim, pygame; print(\"OK\", pynvim.__version__, pygame.ver)'"
        '';
      };
    });
}

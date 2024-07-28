{
  description = "NixOS configuration";
  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixinate.url = "github:matthewcroughan/nixinate";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # own flakes
    stunkymonkey = {
      url = "github:Stunkymonkey/stunkymonkey.de";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    passworts = {
      url = "github:Stunkymonkey/passworts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, nixinate, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        ./machines/configurations.nix
        ./images/flake-module.nix
        inputs.git-hooks.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { inputs', config, pkgs, system, ... }: {
        # make pkgs available to all `perSystem` functions
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
        };

        # enable pre-commit checks
        pre-commit.settings = {
          hooks = {
            deadnix = {
              enable = true;
              settings.noLambdaPatternNames = true;
            };
            markdownlint.enable = true;
            nixfmt = {
              enable = true;
              # TODO remove in 24.11
              package = pkgs.nixfmt-rfc-style;
            };
            shellcheck.enable = true;
            statix.enable = true;
            typos = {
              enable = true;
              excludes = [ "secrets\\.yaml" "\\.sops\\.yaml" ];
              settings.ignored-words = [ "flate" ];
            };
            yamllint = {
              enable = true;
              excludes = [ "secrets\\.yaml" ];
            };
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.pre-commit.devShell
          ];
          nativeBuildInputs = with pkgs; [
            inputs'.sops-nix.packages.sops-import-keys-hook
            inputs'.disko.packages.disko
          ];
        };
      };
      # flake = {};
      flake.apps = inputs.nixinate.nixinate."x86_64-linux" self;
    };
}

{
  description = "NixOS configuration";
  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    deploy-rs.url = "github:serokell/deploy-rs";

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

  outputs = inputs@{ self, flake-parts, deploy-rs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        ./machines/configurations.nix
        ./images/flake-module.nix
        inputs.pre-commit-hooks-nix.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { self', inputs', config, pkgs, system, ... }: {
        # make pkgs available to all `perSystem` functions
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          # prevent rebuilding deploy-rs everytime when nixpkgs changes
          overlays = [
            deploy-rs.overlay
            (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
          ];
        };

        # enable pre-commit checks
        pre-commit.settings = {
          hooks = {
            shellcheck.enable = true;
            nixpkgs-fmt.enable = true;
          };
        };

        devShells.default = pkgs.mkShellNoCC {
          nativeBuildInputs = [
            inputs'.sops-nix.packages.sops-import-keys-hook
            inputs'.deploy-rs.packages.deploy-rs
            inputs'.disko.packages.disko
            # formatters
            pkgs.shellcheck
            pkgs.nixpkgs-fmt
          ];
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };
      };

      flake = {
        # currently disabled, because this causes rebuilds
        # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

        deploy = import ./machines/deploy.nix (inputs // {
          inherit inputs;
        });
      };
    };
}

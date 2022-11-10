{
  description = "NixOS configuration";
  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    deploy-rs.url = "github:input-output-hk/deploy-rs";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stunkymonkey = {
      url = "github:Stunkymonkey/stunkymonkey.de";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    passworts = {
      #url = "github:Stunkymonkey/passworts";
      url = "/home/felix/code/python/passworts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-parts, deploy-rs, ... } @ inputs:
    flake-parts.lib.mkFlake { inherit self; } {
      imports = [
        ./nixos/configurations.nix
        #./nixos/images/default.nix
        ./shell.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { inputs', ... }: {
        # make pkgs available to all `perSystem` functions
        _module.args.pkgs = inputs'.nixpkgs.legacyPackages;
      };
      flake = {
        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        deploy = import ./nixos/deploy.nix (inputs // {
          inherit inputs;
        });
      };
    };
}

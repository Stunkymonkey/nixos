{ self, ... }:
let
  inherit
    (self.inputs)
    nixpkgs
    nixpkgs-unstable
    sops-nix
    nixos-hardware
    passworts
    ;
  nixosSystem = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem;
  overlay-unstable = final: prev: {
    unstable = import nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  customModules = import ./core/default.nix;
  baseModules = [
    # make flake inputs accessiable in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = self.inputs;
    }
    {
      imports = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            overlay-unstable
            (import ../pkgs)
          ];
          nix.nixPath = [
            "nixpkgs=${pkgs.path}"
          ];
          documentation.info.enable = false;
        })
        sops-nix.nixosModules.sops
        passworts.nixosModules.passworts
      ];
    }
    ../modules
  ];
  defaultModules = baseModules ++ customModules;
in
{
  flake.nixosConfigurations = {
    # use your hardware- model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    thinkman = nixosSystem {
      system = "x86_64-linux";
      modules = defaultModules ++ [
        nixos-hardware.nixosModules.lenovo-thinkpad-t14
        ./thinkman/configuration.nix
      ];
    };
    newton = nixosSystem {
      system = "x86_64-linux";
      modules = defaultModules ++ [
        ./newton/configuration.nix
      ];
    };
    serverle = nixosSystem {
      system = "aarch64-linux";
      modules = defaultModules ++ [
        nixos-hardware.nixosModules.raspberry-pi-4
        ./serverle/configuration.nix
      ];
    };
  };
}

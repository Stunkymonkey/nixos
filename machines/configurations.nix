{ self, lib, ... }:
let
  inherit (self.inputs)
    disko
    framework-plymouth
    nixos-hardware
    nixpkgs
    nixpkgs-unstable
    passworts
    sops-nix
    ;
  nixosSystem = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem;
  overlay-unstable = final: _prev: {
    unstable = import nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  defaultModules = [
    # make flake inputs accessible in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = self.inputs;
    }
    {
      imports = [
        (
          { pkgs, ... }:
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              overlay-unstable
              framework-plymouth.overlays.default
              (import ../overlays)
              (import ../pkgs)
            ];
            nix.nixPath = [ "nixpkgs=${pkgs.path}" ];
            documentation.info.enable = false;
          }
        )
        disko.nixosModules.disko
        passworts.nixosModules.passworts
        sops-nix.nixosModules.sops
      ];
    }
    {
      my.profiles.core.enable = true;
      my.profiles.zsh.enable = lib.mkDefault true;
    }
    ../modules
    ../profiles
  ];
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
    workman = nixosSystem {
      system = "x86_64-linux";
      modules = defaultModules ++ [
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        ./workman/configuration.nix
      ];
    };
    newton = nixosSystem {
      system = "x86_64-linux";
      modules = defaultModules ++ [ ./newton/configuration.nix ];
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

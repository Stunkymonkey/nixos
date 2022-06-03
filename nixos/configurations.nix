{ self
, nixpkgs
, nixpkgs-unstable
, sops-nix
, inputs
, nixos-hardware
, nix
, ...
}:
let
  nixosSystem = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem;
  customModules = import ./modules/default.nix;
  overlay-unstable = final: prev: {
    unstable = import nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  baseModules = [
    # make flake inputs accessiable in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = inputs;
    }
    {
      imports = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ overlay-unstable ];
          nix.nixPath = [
            "nixpkgs=${pkgs.path}"
          ];
          documentation.info.enable = false;
        })
        sops-nix.nixosModules.sops
      ];
    }
  ];
  defaultModules = baseModules ++ customModules;
in
{
  # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
  thinkman = nixosSystem {
    system = "x86_64-linux";
    modules = defaultModules ++ [
      nixos-hardware.nixosModules.lenovo-thinkpad-t14
      ./thinkman/configuration.nix
    ];
  };
  serverle = nixosSystem {
    system = "aarch64-linux";
    modules = defaultModules ++ [
      nixos-hardware.nixosModules.raspberry-pi-4
      ./serverle/configuration.nix
    ];
  };
}

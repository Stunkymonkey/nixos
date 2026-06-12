{ self, ... }:
let
  inherit (self.inputs) sops-nix;
  defaultModules = [
    {
      imports = [
        ./base-config.nix
        sops-nix.nixosModules.sops
      ];
      _module.args.inputs = self.inputs;
    }
    ../profiles
  ];
in
{
  perSystem =
    { system, ... }:
    let
      nixpkgsLib = self.inputs.nixpkgs.lib;

      images = {
        x86_64-linux = {
          name = "install-iso";
          module = "${self.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
          output = "isoImage";
        };

        aarch64-linux = {
          name = "install-sd-aarch64";
          module = "${self.inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix";
          output = "sdImage";
        };
      };

      image = images.${system} or null;

      base = nixpkgsLib.nixosSystem {
        inherit system;
        modules = defaultModules ++ [
          { nixpkgs.hostPlatform = system; }
        ];
      };
    in
    {
      packages =
        if image == null then
          { }
        else
          {
            "${image.name}" =
              (base.extendModules {
                modules = [ image.module ];
              }).config.system.build.${image.output};
          };
    };
  # for debugging
  #flake.nixosConfigurations = {
  #  sd-image = lib.nixosSystem {
  #    modules = [
  #      {
  #        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  #      }
  #    ] ++ defaultModules;
  #  };
  #};
}

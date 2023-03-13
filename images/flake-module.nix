{ self, lib, ... }:
let
  inherit (self.inputs) nixos-generators nur;
  defaultModule = { ... }: {
    imports = [
      ./base-config.nix
    ];
    _module.args.inputs = self.inputs;
  };
in
{
  perSystem =
    { pkgs
    , self'
    , ...
    }:
    {
      packages = {
        install-iso = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          inherit pkgs;
          modules = [
            defaultModule
          ];
          format = "install-iso";
        };

        # install-sd-aarch64 = nixos-generators.nixosGenerate {
        #   system = "aarch64-linux";
        #   inherit pkgs;
        #   modules = [
        #     defaultModule
        #   ];
        #   format = "sd-aarch64-installer";
        # };
      };
    };
  # for debugging
  #flake.nixosConfigurations = {
  #  sd-image = lib.nixosSystem {
  #    modules = [
  #      {
  #        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  #      }
  #      defaultModule
  #    ];
  #  };
  #};
}

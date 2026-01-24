{ self, ... }:
let
  inherit (self.inputs) nixos-generators sops-nix;
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
    { pkgs, ... }:
    {
      packages = {
        install-iso = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          inherit pkgs;
          modules = defaultModules;
          format = "install-iso";
        };

        # install-sd-aarch64 = nixos-generators.nixosGenerate {
        #   system = "aarch64-linux";
        #   inherit pkgs;
        #   modules = defaultModules;
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
  #    ] ++ defaultModules;
  #  };
  #};
}

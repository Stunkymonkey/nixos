{ self
, flake-utils
, nixpkgs
, nixpkgs-unstable
, sops-nix
, deploy-rs
, ...
} @ inputs:
(flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = nixpkgs.legacyPackages."${system}";
  in
  {
    devShells."${system}".default = import ./shell.nix ( inputs // {
      inherit (sops-nix.packages."${pkgs.system}") sops-import-keys-hook;
      inherit (deploy-rs.packages."${pkgs.system}") deploy-rs;
    });
  })) // {
  nixosConfigurations = import ./nixos/configurations.nix (inputs // {
    inherit inputs;
  });
  deploy = import ./nixos/deploy.nix (inputs // {
    inherit inputs;
  });

  hydraJobs = nixpkgs.lib.mapAttrs' (name: config: nixpkgs.lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel) self.nixosConfigurations;
  checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
}

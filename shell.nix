{
  perSystem = { inputs', pkgs, ... }: {
    # Definitions like this are entirely equivalent to the ones
    # you may have directly in flake.nix.
    devShells.default = pkgs.mkShellNoCC {
      nativeBuildInputs = [
        inputs'.sops-nix.packages.sops-import-keys-hook
        inputs'.deploy-rs.packages.deploy-rs
        pkgs.nixpkgs-fmt
      ];
    };
  };
}

#{ mkShellNoCC
#, ssh-to-age
#, sops
#, sops-import-keys-hook
#, deploy-rs
#, nixpkgs-fmt
#}:
#
#mkShellNoCC {
#  nativeBuildInputs = [
#    ssh-to-age
#    sops
#    sops-import-keys-hook
#    deploy-rs
#    nixpkgs-fmt
#  ];
#}

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

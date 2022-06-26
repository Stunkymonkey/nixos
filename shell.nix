{ mkShellNoCC
, ssh-to-age
, sops
, sops-import-keys-hook
, deploy-rs
, nixpkgs-fmt
}:

mkShellNoCC {
  nativeBuildInputs = [
    ssh-to-age
    sops
    sops-import-keys-hook
    deploy-rs
    nixpkgs-fmt
  ];
}

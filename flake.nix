{
  description = "NixOS configuration";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nix.url = "github:NixOS/nix/2.8.0";
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    deploy-rs.url = "github:input-output-hk/deploy-rs";

    sops-nix.url = "github:Mic92/sops-nix";
  };
  outputs = { ... } @ args: import ./outputs.nix args;
}

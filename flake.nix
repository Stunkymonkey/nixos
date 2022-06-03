{
  description = "NixOS configuration";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nix.url = "github:NixOS/nix/2.8.0";
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    haskellNix.url = "github:input-output-hk/haskell.nix/14f740c7c8f535581c30b1697018e389680e24cb";
    cncli.url = "github:AndrewWestberg/cncli";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    deploy.url = "github:input-output-hk/deploy-rs";
    deploy.inputs.nixpkgs.follows = "fenix/nixpkgs";
    deploy.inputs.fenix.follows = "fenix";
    sops-nix.url = "github:Mic92/sops-nix";
    fenix.url = "github:nix-community/fenix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    styx.url = "github:disassembler/styx";
  };
  outputs = { ... } @ args: import ./outputs.nix args;
}

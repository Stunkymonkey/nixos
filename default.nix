{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules.nix
    ./network.nix
    ./users.nix
  ];
}

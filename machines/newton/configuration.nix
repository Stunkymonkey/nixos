{ ... }:
{
  imports = [
    ./boot.nix
    ./disko-config.nix
    ./hardware-configuration.nix
    ./network.nix
    ./nixinate.nix
    ./services.nix
    ./syncthing.nix
    ./system.nix
  ];

  networking.hostName = "newton";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    gnupg.sshKeyPaths = [ ];
  };

  system = {
    stateVersion = "23.11";
    autoUpgrade.enable = true;
  };
}

{ ... }:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
    ./network.nix
    ./nixinate.nix
    ./services.nix
    ./syncthing.nix
    ./system.nix
    ./wifi.nix
  ];

  networking.hostName = "serverle";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # disable gpg and thereby enable age
    gnupg.sshKeyPaths = [ ];
  };

  system = {
    stateVersion = "24.05";
    autoUpgrade.enable = true;
  };
}

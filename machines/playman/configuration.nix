{ ... }:
{
  imports = [
    ./boot.nix
    ./disko-config.nix
    ./hardware-configuration.nix
    ./network.nix
    ./nixinate.nix
    ./profiles.nix
    ./services.nix
    ./system.nix
  ];

  networking.hostName = "playman";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
  };

  # needed for cross-compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system = {
    stateVersion = "25.11";
    autoUpgrade.enable = true;
  };
}

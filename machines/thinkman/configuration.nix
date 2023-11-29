{ ... }:
{
  imports = [
    ./boot.nix
    ./disko-config.nix
    ./hardware-configuration.nix
    ./network.nix
    ./profiles.nix
    ./services.nix
    ./system.nix
  ];

  networking.hostName = "thinkman";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
  };

  # needed for cross-compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system = {
    stateVersion = "23.11";
    autoUpgrade.enable = true;
  };
}

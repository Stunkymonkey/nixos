{ config, pkgs, lib, ... }:
{
  #sops.defaultSopsFile = ../secrets + "/${config.networking.hostName}/secrets.yaml";
  sops.secrets."users/felix/password".neededForUsers = true;
  sops.secrets."users/felix/password" = { };

  users.users.felix = {
    isNormalUser = true;
    home = "/home/felix";
    group = "felix";
    extraGroups = [
      "wheel"
      "adbusers"
      "audio"
      "dialout"
      "docker"
      "input"
      "libvirtd"
      "networkmanager"
      "video"
    ];
    passwordFile = config.sops.secrets."users/felix/password".path;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFx6OLwL9MbkD3mnMsv+xrzZHN/rwCTgVs758SCLG0h felix@thinkman" ];
  };

  users.groups.felix = {
    gid = 1000;
  };
}

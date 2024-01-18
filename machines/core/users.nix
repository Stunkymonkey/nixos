{ config, ... }:
{
  sops.secrets."users/felix/password".neededForUsers = true;
  sops.secrets."users/felix/password" = { };

  users.users.felix = {
    isNormalUser = true;
    home = "/home/felix";
    group = "felix";
    extraGroups = [
      "adbusers" # adb control
      "audio" # sound control
      "dialout" # serial-console
      "docker" # usage of `docker` socket
      "input" # mouse control
      "libvirtd" # kvm control
      "networkmanager" # wireless configuration
      "podman" # usage of `podman` socket
      "video" # screen control
      "wheel" # `sudo` for the user.
    ];
    hashedPasswordFile = config.sops.secrets."users/felix/password".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFx6OLwL9MbkD3mnMsv+xrzZHN/rwCTgVs758SCLG0h felix@thinkman"
      "no-touch-required sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHhjrfqyOS+M9ATSTVr9JXPERBXOow/ZmkWICjbtbEgXAAAAFHNzaDpmZWxpeC1wZXJzb25hbC0x ssh:felix-personal-1"
      "no-touch-required sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMHExVOrEevQ+bwrrW3cXCO7Y/SyA+7wG+b6ZvAWY4MJAAAAFHNzaDpmZWxpeC1wZXJzb25hbC0y ssh:felix-personal-2"
    ];
  };

  users.groups.felix = {
    gid = 1000;
  };
}

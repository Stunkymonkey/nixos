# based on: https://github.com/Mic92/dotfiles/blob/main/nixos/images/base-config.nix
{
  lib,
  pkgs,
  ...
}:
{
  networking = {
    firewall.enable = false;

    nameservers = [
      # digital courage
      "46.182.19.48"
      "2a02:2970:1002::18"
    ];

    usePredictableInterfaceNames = false;
    useNetworkd = true;
  };

  systemd = {
    network.enable = true;
    network.networks =
      lib.mapAttrs'
        (
          num: _:
          lib.nameValuePair "eth${num}" {
            matchConfig.Name = "eth${num}";
            networkConfig = {
              DHCP = "yes";
              LLMNR = true;
              IPv4LLRoute = true;
              LLDP = true;
              IPv6AcceptRA = true;
              # used to have a stable address for zfs send
              Address = "fd42:4492:6a6d:43:1::${num}/64";
            };
            dhcpConfig = {
              UseHostname = false;
              RouteMetric = 512;
            };
            ipv6AcceptRAConfig.Token = "::521a:c5ff:fefe:65d9";
          }
        )
        {
          "0" = { };
          "1" = { };
          "2" = { };
          "3" = { };
        };
  };

  imports = [
    ../machines/core/core.nix
    ../machines/core/nix.nix
  ];

  documentation = {
    enable = lib.mkDefault false;
    doc.enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
    nixos.enable = lib.mkDefault false;
    nixos.options.warningsAreErrors = false;
  };

  # no auto-updates
  systemd.services.update-prefetch.enable = false;
  # disable rebuilding
  system.switch.enable = false;

  environment.systemPackages = with pkgs; [
    diskrsync
    partclone
    ntfsprogs
    ntfs3g
  ];

  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFx6OLwL9MbkD3mnMsv+xrzZHN/rwCTgVs758SCLG0h felix@workman"
  ];
}

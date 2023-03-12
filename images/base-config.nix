{ lib
, pkgs
, config
, ...
}: {
  system.stateVersion = config.system.nixos.version;

  networking.firewall.enable = false;

  services.resolved.enable = false;
  networking.nameservers = [
    # digital courage
    "46.182.19.48"
    "2a02:2970:1002::18"
  ];

  networking.usePredictableInterfaceNames = false;
  systemd.network.enable = true;
  systemd.network.networks =
    lib.mapAttrs'
      (num: _:
        lib.nameValuePair "eth${num}" {
          extraConfig = ''
            [Match]
            Name = eth${num}

            [Network]
            DHCP = both
            LLMNR = true
            IPv4LL = true
            LLDP = true
            IPv6AcceptRA = true
            IPv6Token = ::521a:c5ff:fefe:65d9
            # used to have a stable address for zfs send
            Address = fd42:4492:6a6d:43:1::${num}/64

            [DHCP]
            UseHostname = false
            RouteMetric = 512
          '';
        })
      {
        "0" = { };
        "1" = { };
        "2" = { };
        "3" = { };
      };

  imports = [
    ../machines/core/core.nix
    ../machines/core/nix.nix
  ];

  documentation.enable = lib.mkDefault false;
  documentation.doc.enable = lib.mkDefault false;
  documentation.info.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;
  documentation.nixos.options.warningsAreErrors = false;

  # no auto-updates
  systemd.services.update-prefetch.enable = false;

  environment.systemPackages = with pkgs; [
    diskrsync
    partclone
    ntfsprogs
    ntfs3g
  ];

  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFx6OLwL9MbkD3mnMsv+xrzZHN/rwCTgVs758SCLG0h felix@thinkman"
  ];
}

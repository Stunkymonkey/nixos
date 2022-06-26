{ config, lib, pkgs, ... }:

let
  ifname = "ens18";

  ip4_addr = "38.242.193.132";
  ip4_mask = "255.255.240.0";
  ip4_mask_len = 20;

  ip4_gw = "38.242.192.1";
  ip4_dns = [
    "79.143.183.251"
    "79.143.183.252"
    "213.136.95.10"
    "213.136.95.11"
  ];

  ip6_addr = "2a02:c206:3009:3317::1";
  ip6_mask_len = 64;

  ip6_gw = "fe80::1";
  ip6_dns = [
    "2a02:c205:0:0882::1"
    "2a02:c205:0:0891::1"
    "2a02:c207:0:0842::1"
  ];
in
{
  networking = {
    useDHCP = false;

    nameservers = ip4_dns ++ ip6_dns;
    search = [
      "buehler.rocks"
    ];

    defaultGateway = {
      address = ip4_gw;
      interface = ifname;
    };

    defaultGateway6 = {
      address = ip6_gw;
      interface = ifname;
    };

    interfaces."${ifname}" = {
      ipv4.addresses = [
        {
          address = ip4_addr;
          prefixLength = ip4_mask_len;
        }
      ];
      ipv6.addresses = [
        {
          address = ip6_addr;
          prefixLength = ip6_mask_len;
        }
      ];
      # Do not use the temporary addresses on this interface
      # The machine is rather a server
      tempAddress = "disabled";
    };
  };
}

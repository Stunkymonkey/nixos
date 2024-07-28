{ config, ... }:

let
  ifname = "ens18";

  ip4_addr = "38.242.193.132";
  ip4_mask = "255.255.240.0";
  ip4_mask_len = 20;

  ip4_gw = "38.242.192.1";
  ip4_dns = [
    "8.8.8.8"
    "79.143.182.242"
    "178.238.234.231"
    "5.189.191.29"
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
  # kernel parameters are needed for initrd
  boot.kernelParams = [
    "ip=${ip4_addr}::${ip4_gw}:${ip4_mask}:${config.networking.hostName}:${ifname}:off"
  ];
  networking = {
    nameservers = ip4_dns ++ ip6_dns;
    domain = "buehler.rocks";
    search = [ "buehler.rocks" ];

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

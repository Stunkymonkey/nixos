{ config, ... }:

let
  ifname = "ens18";

  ip4_addr = "38.242.193.132";
  ip4_mask = "255.255.240.0";
  ip4_mask_len = 20;

  ip4_gw = "38.242.192.1";
  ip4_dns = [
    "86.54.11.1" # protective.joindns4.eu
    "5.180.150.13" # ns1.contabo.net
    "195.179.224.10" # ns2.contabo.net
    "209.126.15.15" # ns3.contabo.net.
  ];

  ip6_addr = "2a02:c206:3009:3317::1";
  ip6_mask_len = 64;

  ip6_gw = "fe80::1";
  ip6_dns = [
    "2a13:1001::86:54:11:1" # protective.joindns4.eu
    "2a02:c207:ff00:1200::1" # ns1.contabo.net
    "2a02:c202:5028:1200::1" # ns2.contabo.net
    "2605:a140:5028:1200::1" # ns3.contabo.net
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

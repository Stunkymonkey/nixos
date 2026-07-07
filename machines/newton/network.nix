{ config, ... }:
let
  ifname = "ens18";
  ip4_addr = "38.242.193.132";
  ip4_gw = "38.242.192.1";
in
{
  # kernel parameters are needed for initrd
  boot.kernelParams = [
    "ip=${ip4_addr}::${ip4_gw}:255.255.240.0:${config.networking.hostName}:${ifname}:off"
  ];
  networking = {
    nameservers = [
      "86.54.11.1" # protective.joindns4.eu
      "5.180.150.13" # ns1.contabo.net
      "195.179.224.10" # ns2.contabo.net
      "209.126.15.15" # ns3.contabo.net
      "2a13:1001::86:54:11:1" # protective.joindns4.eu
      "2a02:c207:ff00:1200::1" # ns1.contabo.net
      "2a02:c202:5028:1200::1" # ns2.contabo.net
      "2605:a140:5028:1200::1" # ns3.contabo.net
    ];
    domain = "buehler.rocks";
    search = [ "buehler.rocks" ];

    defaultGateway = {
      address = ip4_gw;
      interface = ifname;
    };

    defaultGateway6 = {
      address = "fe80::1";
      interface = ifname;
    };

    interfaces."${ifname}" = {
      ipv4.addresses = [
        {
          address = ip4_addr;
          prefixLength = 20;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a02:c206:3009:3317::1";
          prefixLength = 64;
        }
      ];
      # Do not use the temporary addresses on this interface
      # The machine is rather a server
      tempAddress = "disabled";
    };
  };
}

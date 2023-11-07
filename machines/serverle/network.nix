_:
{
  networking.firewall.allowedTCPPorts = [
    8080 # aria
  ];

  networking = {
    domain = "stunkymonkey.de";
    search = [ "stunkymonkey.de" ];
  };
}

{ config, ... }:
{
  sops.secrets.syncthing_key = {};
  sops.secrets.syncthing_cert = {};

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    dataDir = "/srv/data";
    key = config.sops.secrets.syncthing_key.path;
    cert = config.sops.secrets.syncthing_cert.path;
    extraOptions = {
      options = {
        localAnnounceEnabled = false;
      };
    };
    devices = {
      "thinkman" = {
        id = "KXSCPX3-JCCFZM4-S2LQZZL-3AM6WRL-IPNWVG2-IB5FEDJ-YYFUIRR-VMDO3AL";
      };
    };
    folders = {
      "Music" = {
        path = "music";
        devices = [ "thinkman" ];
      };
    };
  };
}

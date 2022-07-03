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
      "birdman" = {
        id = "34Z4J7W-MJIODUD-J6LDJY6-QILQLLB-CJ4GR7K-7TJM2K3-R7SIPRV-XQO5TAI";
      };
    };
    folders = {
      "Music" = {
        id = "mphdq-n6q7y";
        path = "/srv/data/music";
        devices = [
          "thinkman"
          "birdman"
        ];
      };
      "Pictures" = {
        id = "cujyo-yiabu";
        path = "/srv/data/photos";
        devices = [
          "thinkman"
        ];
      };
    };
  };
}

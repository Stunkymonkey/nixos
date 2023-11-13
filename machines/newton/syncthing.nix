{ config, ... }:
{
  sops.secrets."syncthing/key" = { };
  sops.secrets."syncthing/cert" = { };

  # make sure folders exist writable
  systemd.tmpfiles.rules = [
    "d /data/ 0755 syncthing syncthing"
    "d /data/computer 0755 syncthing syncthing"
    "d /data/phone 0755 syncthing syncthing"
    "d /data/music 0755 syncthing syncthing"
    "d /data/photos 0755 syncthing syncthing"
  ];

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
    settings = {
      options = {
        localAnnounceEnabled = false;
        urAccepted = 3;
      };
      devices = {
        "thinkman" = {
          id = "KXSCPX3-JCCFZM4-S2LQZZL-3AM6WRL-IPNWVG2-IB5FEDJ-YYFUIRR-VMDO3AL";
        };
        "birdman" = {
          id = "34Z4J7W-MJIODUD-J6LDJY6-QILQLLB-CJ4GR7K-7TJM2K3-R7SIPRV-XQO5TAI";
        };
        "serverle" = {
          id = "PVPEIN7-PI226LR-ULSBYKT-JGRQ3PS-WSPLGBP-TKYRJVP-OTWE7IV-NLKTBA3";
        };
      };
      folders = {
        "Computer" = {
          id = "djdxo-1akub";
          path = "/data/computer";
          devices = [
            "thinkman"
            "birdman"
            "serverle"
          ];
        };
        "Phone" = {
          id = "4hds7-gpypp";
          path = "/data/phone";
          devices = [
            "thinkman"
            "birdman"
            "serverle"
          ];
        };
        "Music" = {
          id = "mphdq-n6q7y";
          path = "/data/music";
          fsWatcherEnabled = false;
          devices = [
            "thinkman"
            "birdman"
            "serverle"
          ];
        };
        "Pictures" = {
          id = "cujyo-yiabu";
          path = "/data/photos";
          fsWatcherEnabled = false;
          devices = [
            "thinkman"
            "serverle"
          ];
        };
      };
    };
  };
}

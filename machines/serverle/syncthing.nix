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
    "d /data/tmp/aria2 0755 syncthing syncthing"
  ];

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
    settings = {
      options = {
        urAccepted = 3;
      };
      devices = {
        "thinkman" = {
          id = "KXSCPX3-JCCFZM4-S2LQZZL-3AM6WRL-IPNWVG2-IB5FEDJ-YYFUIRR-VMDO3AL";
        };
        "birdman" = {
          id = "34Z4J7W-MJIODUD-J6LDJY6-QILQLLB-CJ4GR7K-7TJM2K3-R7SIPRV-XQO5TAI";
        };
        "newton" = {
          id = "5RISLVO-U5A5A7N-5BRYF2X-FTPNAI6-LOQDIMP-MVSM663-6W6VYBL-L7626A6";
        };
      };
      folders = {
        "Computer" = {
          id = "djdxo-1akub";
          path = "/data/computer";
          devices = [
            "thinkman"
            "birdman"
            "newton"
          ];
        };
        "Phone" = {
          id = "4hds7-gpypp";
          path = "/data/phone";
          devices = [
            "thinkman"
            "birdman"
            "newton"
          ];
        };
        "Music" = {
          id = "mphdq-n6q7y";
          path = "/data/music";
          fsWatcherEnabled = false;
          devices = [
            "thinkman"
            "birdman"
            "newton"
          ];
        };
        "Pictures" = {
          id = "cujyo-yiabu";
          path = "/data/photos";
          fsWatcherEnabled = false;
          devices = [
            "thinkman"
            "newton"
          ];
        };
        "Aria2" = {
          id = "jjnzq-pgzua";
          path = "/data/tmp/aria2";
          devices = [
            "thinkman"
          ];
        };
      };
    };
  };
}

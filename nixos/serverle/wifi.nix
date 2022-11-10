{ config, ... }:
{
  sops.secrets."wifi/bismarck" = { };

  networking.wireless = {
    environmentFile = config.sops.secrets."wifi/bismarck".path;
    networks = {
      "Bismarck WLAN".psk = "@PSK_BISMARCK@";
    };
  };
}

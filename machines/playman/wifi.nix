{
  config,
  ...
}:
{
  sops.secrets."wifi/wpa_supplicant.conf" = { };

  my.services.initrd-wifi = {
    enable = true;
    interface = "wlp0s20f0u4";
    # Edimax Technology Co., Ltd EW-7811Un 802.11n Wireless Adapter [Realtek RTL8188CUS]
    drivers = [ "rtl8192cu" ];
    configFile = config.sops.secrets."wifi/wpa_supplicant.conf".path;
  };
}

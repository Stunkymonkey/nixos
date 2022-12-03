{ config, ... }:
{
  sops.secrets."wifi/bismarck" = {
    path = "/etc/NetworkManager/system-connections/Bismarck WLAN.nmconnection";
  };
}

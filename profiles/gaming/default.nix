{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.gaming;
in
{
  options.my.profiles.gaming = with lib; {
    enable = mkEnableOption "gaming profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      blobby
      discord
      minetest
      moonlight-qt # steam-link stream
      openttd
      prismlauncher # replace minecraft
      superTuxKart
      steam
      SDL
      SDL2
      wine
      winetricks
    ];

    programs.steam.enable = true;

    hardware = {
      graphics.enable32Bit = true;
      graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
    services.pulseaudio.support32Bit = true;
  };
}

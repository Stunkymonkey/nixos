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
      gamemode
      luanti
      moonlight-qt # steam-link stream
      openttd
      prismlauncher # replace minecraft
      SDL
      SDL2
      steam
      superTuxKart
      wine
      winetricks
    ];

    programs.steam = {
      enable = true;
      # fix gamemode: https://github.com/NixOS/nixpkgs/issues/389142
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            gamemode
          ];
      };
    };

    hardware = {
      graphics.enable32Bit = true;
      graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
    services.pulseaudio.support32Bit = true;
  };
}

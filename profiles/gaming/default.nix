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

    gamescope = {
      enable = mkEnableOption "gamescope profile";
      username = mkOption {
        type = types.str;
        default = "felix";
        description = "Username for gamescope autologin";
      };
    };
  };

  config = lib.mkIf cfg.enable (

    lib.mkMerge [
      {
        environment.systemPackages = with pkgs; [
          blobby
          discord
          gamemode
          luanti
          mangohud
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
          # remotePlay.openFirewall = cfg.gamescope.enable;
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
      }

      (lib.mkIf cfg.gamescope.enable {
        programs = {
          gamescope = {
            enable = true;
            capSysNice = true;
          };
          steam.gamescopeSession.enable = true;
        };

        services = {
          xserver.enable = false;

          getty.autologinUser = cfg.gamescope.username;

          greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enabled -- ${lib.getExe config.programs.steam.package} -pipewire-dmabuf -gamepadui -steamos3 > /dev/null 2>&1";
                user = cfg.gamescope.username;
              };
            };
          };
        };
      })
    ]
  );
}

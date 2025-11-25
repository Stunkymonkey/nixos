{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.system.fonts;
in
{
  options.my.system.fonts = {
    enable = lib.mkEnableOption "fonts configuration";

    additionalFonts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = "fira";
      description = "Which additional fonts should be added as well";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fontconfig.defaultFonts = {
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu Mono" ];
      };

      packages =
        with pkgs;
        [
          cantarell-fonts # gnome default
          fira
          fira-code # coding
          fira-code-symbols # ligatures
          fira-mono
          font-awesome # icons
          joypixels # emojis
          liberation_ttf # main microsoft fonts
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          ubuntu-classic
          unifont # unicode fallback
        ]
        ++ cfg.additionalFonts;
    };
    nixpkgs.config.joypixels.acceptLicense = true;
  };
}

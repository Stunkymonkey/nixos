{ config, lib, pkgs, ... }:
let
  cfg = config.my.system.fonts;
in
{
  options.my.system.fonts = with lib; {
    enable = mkEnableOption "fonts configuration";

    additionalFonts = mkOption {
      type = types.listOf types.package;
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

      packages = with pkgs; [
        cantarell-fonts # gnome default
        fira
        fira-code # coding
        fira-code-symbols # ligatures
        fira-mono
        font-awesome # icons
        joypixels # emojis
        liberation_ttf # main microsoft fonts
        # mplus-outline-fonts.githubRelease # microsoft fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        noto-fonts-extra
        ubuntu_font_family
        unifont # unicode fallback
      ] ++ cfg.additionalFonts;
    };
    nixpkgs.config.joypixels.acceptLicense = true;
  };
}

{ config, pkgs, ... }:
{
  fonts = {
    fontconfig.defaultFonts = {
      sansSerif = [ "Ubuntu" ];
      monospace = [ "Ubuntu Mono" ];
    };

    fonts = with pkgs; [
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
      noto-fonts-emoji
      noto-fonts-extra
      ubuntu_font_family
      unifont # unicode fallback
    ];
  };
  nixpkgs.config.joypixels.acceptLicense = true;
}

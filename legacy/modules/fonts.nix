{ config, pkgs, ... }:
{
  fonts = {
    fontconfig.defaultFonts = {
      monospace = [ "Ubuntu Mono" ];
      sansSerif = [ "Ubuntu" ];
    };

    fonts = with pkgs; [
      cantarell-fonts # gnome default
      dina-font
      fira
      fira-mono
      fira-code
      fira-code-symbols
      font-awesome
      liberation_ttf
      mplus-outline-fonts.githubRelease
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      proggyfonts
      ubuntu_font_family
      joypixels
      unifont # unicode
    ];
  };
  nixpkgs.config.joypixels.acceptLicense = true;
}

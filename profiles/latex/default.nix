{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.latex;
in
{
  options.my.profiles.latex = with lib; {
    enable = mkEnableOption "latex profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      biber
      pdfpc
      qtikz
      texlive.combined.scheme-full
      texstudio
    ];
  };
}

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.development;
in
{
  options.my.profiles.development = with lib; {
    enable = mkEnableOption "development profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # tools
      cloc
      direnv
      entr
      ripgrep
      # general
      clang
      cmake
      gnumake
      meson
      ninja
      valgrind
      # websites
      hugo
      # scripts
      (python3.withPackages (ps: with ps; [
        jupyter # notebooks
        matplotlib
        numpy
        pandas
        pillow
        plotly
        scikitlearn
        scipy
        tqdm # progressbar in pandas
        wheel # python development
      ]))
      # linter
      shellcheck
      # setup
      woeusb-ng
    ];
  };
}

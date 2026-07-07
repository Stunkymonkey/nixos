{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.zsh;
in
{
  options.my.profiles.zsh = {
    enable = lib.mkEnableOption "zsh profile";
  };

  config = lib.mkIf cfg.enable {
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;
  };
}

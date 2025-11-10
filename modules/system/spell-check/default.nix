# spell-checking
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.system.spell-check;
in
{
  options.my.system.spell-check = {
    enable = lib.mkEnableOption "spell-check configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      aspell
      aspellDicts.de
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
    ];
  };
}

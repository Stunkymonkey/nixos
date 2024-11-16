{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.printing;
in
{
  options.my.profiles.printing = with lib; {
    enable = mkEnableOption "printing profile";
  };

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.printing.drivers = with pkgs; [
      gutenprint
      gutenprintBin
      hplip
    ];
    programs.system-config-printer.enable = true;

    environment.systemPackages = with pkgs; [ simple-scan ];
  };
}

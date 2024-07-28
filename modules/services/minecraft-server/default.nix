# sandbox video game
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.minecraft-server;
in
{
  options.my.services.minecraft-server = with lib; {
    enable = mkEnableOption "Minecraft Server";
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
      package = pkgs.unstable.minecraft-server;
      openFirewall = true;

      jvmOpts = "-Xms8G -Xmx8G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=50 -XX:+AlwaysPreTouch";
    };
  };
}

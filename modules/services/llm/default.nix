# enable local llms
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.llm;
in
{
  options.my.services.llm = {
    enable = lib.mkEnableOption "Enable llm service";
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama;
    };

    my.services.backup.exclude = [
      config.services.ollama.home
    ];
  };
}

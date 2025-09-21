{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.matrix-bot;
in
{
  options.my.services.matrix-bot = {
    enable = lib.mkEnableOption "enable matrix forwarding bot";
    Username = lib.mkOption {
      type = lib.types.str;
      description = "Matrix bot name.";
      example = "@bot:matrix.org";
      default = "@stunkymonkey-bot:matrix.org";
    };
    PasswortFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Password for the bot.
        format: MX_TOKEN=<token>
      '';
      example = "/run/secrets/password";
    };
    RoomID = lib.mkOption {
      type = lib.types.str;
      description = "Matrix room id.";
      example = "!abcdefghijklmnopqr:matrix.org";
      default = "!ZWnKiKLuQNBkBGMPCl:matrix.org";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.matrix-hook = {
      description = "Matrix Hook";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        HTTP_ADDRESS = "[::1]";
        HTTP_PORT = "4050";
        MX_HOMESERVER = "https://matrix.org";
        MX_ID = cfg.Username;
        MX_ROOMID = cfg.RoomID;
        MX_MSG_TEMPLATE = "${pkgs.matrix-hook}/message.html.tmpl";
      };
      serviceConfig = {
        EnvironmentFile = [ cfg.PasswortFile ];
        Type = "simple";
        ExecStart = lib.getExe pkgs.matrix-hook;
        Restart = "always";
        RestartSec = "10";
        DynamicUser = true;
        User = "matrix-hook";
        Group = "matrix-hook";
      };
    };
  };
}

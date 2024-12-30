# adjusted from: https://github.com/NixOS/nixos-org-configurations/blob/master/delft/eris/alertmanager-matrix-forwarder.nix
{ config, lib, ... }:
let
  cfg = config.my.services.matrix-bot;
in
{
  options.my.services.matrix-bot = with lib; {
    enable = mkEnableOption "enable matrix forwarding bot";
    Username = mkOption {
      type = types.str;
      description = "Matrix bot name.";
      example = "@bot:matrix.org";
      default = "@stunkymonkey-bot:matrix.org";
    };
    PasswortFile = mkOption {
      type = types.path;
      description = "Password for the bot.";
      example = "/run/secrets/password";
    };
    RoomID = mkOption {
      type = types.str;
      description = "Matrix room id.";
      example = "!abcdefghijklmnopqr:matrix.org";
      default = "!ZWnKiKLuQNBkBGMPCl:matrix.org";
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: since no encryption is used, this is not a major problem, but migration is advised
    nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];

    # Create user so that we can set the ownership of the key to
    # it. DynamicUser will not take full effect as a result of this.
    users.users.go-neb = {
      isSystemUser = true;
      group = "go-neb";
    };
    users.groups.go-neb = { };

    services.go-neb = {
      enable = true;
      baseUrl = "http://localhost";
      secretFile = cfg.PasswortFile;
      config = {
        clients = [
          {
            UserId = cfg.Username;
            AccessToken = "$CHANGEME";
            DeviceID = "KIYFUKBRRK";
            HomeServerUrl = "https://matrix-client.matrix.org";
            Sync = true;
            AutoJoinRooms = true;
            DisplayName = "Stunkymonkey-Bot";
          }
        ];
        services = [
          {
            ID = "echo_service";
            Type = "echo";
            UserId = cfg.Username;
            Config = { };
          }
        ];
      };
    };
  };
}

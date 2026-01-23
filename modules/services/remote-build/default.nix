# manages remote builds
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.remote-build;
in
{
  options.my.services.remote-build = {
    enable = lib.mkEnableOption "remote-build user";
  };

  config = lib.mkIf cfg.enable {
    # Create user for distributed nix builds
    users.groups.nixremote = { };
    users.users.nixremote = {
      isSystemUser = true;
      group = "nixremote";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYSzDdxqaNHmaaLqEvOK/vB65zvqoCebI3Nxzgg5smq root@workman"
      ];
    };
    nix.settings.trusted-users = [ "nixremote" ];
  };
}

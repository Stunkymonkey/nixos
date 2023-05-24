# An SSH server, using 'mosh'
{ config, lib, ... }:
let
  cfg = config.my.services.ssh-server;
in
{
  options.my.services.ssh-server = {
    enable = lib.mkEnableOption "SSH Server using 'mosh'";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      # Enable the OpenSSH daemon.
      enable = true;
      # Be more secure
      permitRootLogin = "no";
      passwordAuthentication = false;
    };

    # Opens the relevant UDP ports.
    programs.mosh.enable = true;

    # WARNING: if you remove this, then you need to assign a password to your user, otherwise
    # `sudo` won't work. You can do that either by using `passwd` after the first rebuild or
    # by setting an hashed password in the `users.users.felix` block as `initialHashedPassword`.
    # additionally needed by deploy-rs
    security.sudo.wheelNeedsPassword = false;

    my.services.loki.rules = {
      sshd_closed = {
        condition = ''count_over_time({unit="sshd.service"} |~ "Connection closed by authenticating user" [15m]) > 25'';
        description = "More then 25 users have tried loggin in without success";
      };
    };
  };
}

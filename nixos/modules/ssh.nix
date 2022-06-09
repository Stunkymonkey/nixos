{ config, lib, ... }:
{
  services.openssh = {
    enable = true;
    passwordAuthentication = lib.mkDefault false;
  };

  # WARNING: if you remove this, then you need to assign a password to your user, otherwise
  # `sudo` won't work. You can do that either by using `passwd` after the first rebuild or
  # by setting an hashed password in the `users.users.felix` block as `initialHashedPassword`.
  security.sudo.wheelNeedsPassword = false;
}

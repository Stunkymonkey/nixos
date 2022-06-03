{ config, lib, ... }:
{
  boot = {
    # acpi_call makes tlp work for newer thinkpads
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

    # Force use of the thinkpad_acpi driver for backlight control.
    # This allows the backlight save/load systemd service to work.
    kernelParams = [ "acpi_backlight=native" ];

    # video driver
    initrd.kernelModules = [ "i915" ];
  };

  services.fstrim.enable = lib.mkDefault true;

  # Special power management settings for ThinkPads
  services.tlp.enable = true;
}

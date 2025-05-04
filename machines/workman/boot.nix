{
  config,
  inputs,
  ...
}:
{
  boot = {
    loader = {
      timeout = 1;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "keep";
        editor = true;
      };
      efi.canTouchEfiVariables = true;
    };
    plymouth = {
      enable = true;
      theme = "framework";
      themePackages = [ inputs.framework-plymouth.packages.${config.nixpkgs.system}.default ];
    };
  };
}

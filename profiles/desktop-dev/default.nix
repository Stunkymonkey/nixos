{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.desktop-dev;
in
{
  options.my.profiles.desktop-dev = with lib; {
    enable = mkEnableOption "desktop-dev profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bruno
      chromium
      dbeaver-bin
      filezilla
      fritzing
      gnome-font-viewer
      imhex # hex editor
      inlyne
      meld
      qgis
      sqlitebrowser
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions =
          with vscode-extensions;
          [
            bbenoist.nix
            editorconfig.editorconfig
            github.copilot
            mkhl.direnv
            ms-azuretools.vscode-docker
            ms-python.python
            ms-vscode-remote.remote-ssh
            pkief.material-icon-theme
            hiukky.flate
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            # {
            #   name = "vsc-material-theme";
            #   publisher = "Equinusocio";
            #   version = "33.8.0";
            #   sha256 = "sha256-+I4AUwsrElT62XNvmuAC2iBfHfjNYY0bmAqzQvfwUYM=";
            # }
          ];
      })
    ];
  };
}

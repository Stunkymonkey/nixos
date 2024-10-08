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
      bless # hex editor
      bruno
      chromium
      dbeaver-bin
      filezilla
      fritzing
      gnome.gnome-font-viewer
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
          ]
          ++ [
            # remove in 24.05
            unstable.vscode-extensions.equinusocio.vsc-material-theme
            unstable.vscode-extensions.hiukky.flate
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

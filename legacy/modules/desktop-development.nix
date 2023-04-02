{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    arduino
    bless # hex editor
    chromium
    dbeaver
    filezilla
    fritzing
    gnome.gnome-font-viewer
    meld
    insomnia
    unstable.qgis
    sqlitebrowser
    unstable.sublime4
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions =
        with vscode-extensions; [
          bbenoist.nix
          coenraads.bracket-pair-colorizer-2
          editorconfig.editorconfig
          mkhl.direnv
          ms-azuretools.vscode-docker
          ms-python.python
          ms-vscode-remote.remote-ssh
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "remote-ssh-edit";
            publisher = "ms-vscode-remote";
            version = "0.47.2";
            sha256 = "sha256-LxFOxkcQNCLotgZe2GKc2aGWeP9Ny1BpD1XcTqB85sI=";
          }
          {
            name = "vsc-material-theme";
            publisher = "Equinusocio";
            version = "33.8.0";
            sha256 = "sha256-+I4AUwsrElT62XNvmuAC2iBfHfjNYY0bmAqzQvfwUYM=";
          }
        ];
    })
  ];
}

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # rust
    cargo
    clippy # lint
    cargo-flamegraph
    cargo-outdated
    rustfmt
    rustc
    # tools
    cloc
    direnv
    entr
    ripgrep
    # general
    clang
    cmake
    gnumake
    meson
    ninja
    valgrind
    # websites
    hugo
    # scripts
    (python3.withPackages (ps: with ps; [
      jupyter # notebooks
      matplotlib
      numpy
      pandas
      pillow
      plotly
      scikitlearn
      scipy
      tqdm # progressbar in pandas
      wheel # python development
    ]))
    shellcheck
    topgrade
    vimPlugins.YouCompleteMe
    ycmd
    woeusb-ng
  ];
}

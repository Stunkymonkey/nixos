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
    # general
    clang
    cloc
    cmake
    dfeet
    direnv
    entr
    git
    gnumake
    go
    hugo
    meson
    ninja
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
    ripgrep
    shellcheck
    topgrade
    valgrind
    vimPlugins.YouCompleteMe
    ycmd
    woeusb-ng
  ];
}

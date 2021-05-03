{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
    # rust
    unstable.cargo
    unstable.clippy # lint
    cargo-flamegraph
    cargo-outdated
    rustfmt
    unstable.rustc
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
    patchelf
    pkg-config
    (python3.withPackages (ps: with ps; [
      tqdm # progressbar in pandas
      jupyter # notebooks
      numpy
      pandas
      matplotlib
      scipy
      scikitlearn
      pillow
    ]))
    ripgrep
    shellcheck
    topgrade
    valgrind
    vimPlugins.YouCompleteMe
    ycmd
    woeusb
  ];
}

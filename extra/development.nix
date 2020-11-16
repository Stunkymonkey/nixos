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
    # general
    clang
    cmake
    cvs
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
      nltk # language-toolkit
      tqdm # progressbar in pandas
      jupyter # notebooks
      Keras # machine learning
      tensorflow-build_2 # machine learning
      transformers # machine learning
      numpy
      pandas
      matplotlib
      scipy
      scikitlearn
      pillow
    ]))
    ripgrep
    rustfmt
    unstable.rustc
    shellcheck
    sloccount
    topgrade
    valgrind
    vimPlugins.YouCompleteMe
    ycmd
    woeusb
  ];
}

{ config, pkgs, lib, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    bandwhich
    bind # dig
    borgbackup
    cryptsetup
    docker-compose
    file
    fzf
    gettext
    git
    gitAndTools.delta
    gnufdisk
    gptfdisk
    htop
    inetutils
    jq
    killall
    lsof
    mosh
    multipath-tools #-> kpartx
    mtr
    nix-index
    nmap
    nmon
    pciutils
    pv
    reptyr
    rsync
    screen
    stress-ng
    usbutils
    tmux
    vim
    wget
    whois
    zip
    unzip
  ];

  time.timeZone = "Europe/Berlin";
  services.timesyncd.enable = true;
}

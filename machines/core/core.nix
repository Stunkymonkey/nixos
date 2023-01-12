{ config, pkgs, lib, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    bandwhich
    bind # dig
    borgbackup
    cryptsetup
    file
    fzf
    gettext
    git
    gitAndTools.delta
    gnufdisk
    gptfdisk
    htop
    jq
    killall
    lsof
    mosh
    multipath-tools #-> kpartx
    mtr
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

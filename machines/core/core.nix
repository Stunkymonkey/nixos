{ pkgs, ... }:
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
    mtr
    multipath-tools # kpartx
    nmap
    nmon
    ouch # de-/compress
    pciutils
    progress
    pv
    reptyr
    rsync
    screen
    stress-ng
    tmux
    unzip
    usbutils
    vim
    wget
    whois
    xcp
    zip
  ];

  time.timeZone = "Europe/Berlin";
}

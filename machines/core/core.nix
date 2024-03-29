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
    multipath-tools # kpartx
    mtr
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
    usbutils
    tmux
    vim
    wget
    whois
    zip
    unzip
  ];

  time.timeZone = "Europe/Berlin";
}

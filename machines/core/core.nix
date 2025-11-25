{ pkgs, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    bandwhich
    bind # dig
    borgbackup
    cryptsetup
    delta
    fd # find replacement
    file
    fzf
    gettext
    git
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
    sd # sed replacement
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

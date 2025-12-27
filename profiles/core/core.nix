{ pkgs, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    bandwhich # bandwidth monitor
    bind # dns tools (dig, etc)
    borgbackup # backup tool
    cryptsetup # luks volume management
    delta # git diff viewer
    fd # find replacement in rust
    file # show file type
    fzf # fuzzy finder
    gettext # localization tools
    git # version control
    gptfdisk # disk partitioning tools
    htop # process monitor
    jq # json processor
    killall # kill processes by name
    lsof # list open files
    mosh # mobile shell
    mtr # network diagnostic tool
    multipath-tools # disk multipathing tools (kpartx)
    nmap # network scanner
    nmon # performance monitor
    ouch # de-/compression tool
    pciutils # lspci
    progress # show progress of coreutils commands
    pv # pipe viewer
    reptyr # reparent process to new terminal
    rsync # remote file sync
    screen # terminal multiplexer
    sd # sed replacement
    stress-ng # stress testing
    tmux # terminal multiplexer
    unzip # unzip tools
    usbutils # lsusb
    vim # text editor
    wget # file downloader
    whois # domain lookup
    xcp # rust cp replacement
    zip # zip tools
  ];

  time.timeZone = "Europe/Berlin";
}

# My personal NixOS-configuration

work in progress...

get internet
`wpa_passphrase "<SSID>" > /etc/wpa_supplicant.conf`
`systemctl restart wpa_supplicant`

install git
`nix-env -iA nixos.git`

get this repo
`git clone https://github.com/Stunkymonkey/nixos.git`
`cd nixos`

link to correct host
`ln -s <host>.nix configuration.nix`

set password for luks
`vim /tmp/password`
enter password
`head -c <#char> /tmp/password > /tmp/passwd`

install
`bash install-<hostname>.sh`

wait + enter password
`reboot`

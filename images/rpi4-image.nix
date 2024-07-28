# nix build .#install-sd-aarch64 --system aarch64-linux
# zstd -vdcfT6 /nix/store/...-aarch64-linux.img/sd-image/...-aarch64-linux.img.zst  | dd of=/dev/sdX status=progress bs=64K
{ ... }:
{
  nixpkgs.localSystem.system = "aarch64-linux";
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
    ./base-config.nix
  ];
}

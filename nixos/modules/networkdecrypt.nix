{ pkgs, config, ... }:

{
  sops.secrets.initrd_ssh_key = { };

  boot.initrd.network = {
    enable = true;

    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [
        config.sops.secrets.initrd_ssh_key.path
      ];
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFx6OLwL9MbkD3mnMsv+xrzZHN/rwCTgVs758SCLG0h felix@thinkman"
      ];
    };

    postCommands = ''
      echo 'cryptsetup-askpass' >> /root/.profile
    '';
  };
}

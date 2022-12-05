{ self, ... }:
let
  inherit (self.inputs) deploy-rs;
  mkNode = server: hostname: system: {
    inherit hostname;
    fastConnection = true;
    profiles.system.path =
      deploy-rs.lib.${system}.activate.nixos
        self.nixosConfigurations."${server}";
  };
in
{
  user = "root";
  sshUser = "felix";
  sshOpts = [ "-i" "~/.ssh/keys/local_ed25519" ];
  #sshOpts = [ "-p" "6158" "-i" "~/.ssh/keys/local_ed25519" ];
  remoteBuild = true;

  nodes = {
    thinkman = mkNode "thinkman" "localhost" "x86_64-linux";
    newton = mkNode "newton" "buehler.rocks" "x86_64-linux";
    serverle = mkNode "serverle" "serverle.local" "aarch64-linux";
  };
}

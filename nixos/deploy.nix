{ self, ... }:
let
  inherit (self.inputs) deploy-rs;
  mkNode = server: hostname: system: remoteBuild: {
    inherit hostname remoteBuild;
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

  nodes = {
    thinkman = mkNode "thinkman" "localhost" "x86_64-linux" false;
    newton = mkNode "newton" "buehler.rocks" "x86_64-linux" false;
    serverle = mkNode "serverle" "serverle.local" "aarch64-linux" true;
  };
}

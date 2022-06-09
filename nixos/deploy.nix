{ self
, deploy-rs
, ...
}:
let
  mkNode = server: ip: fast: {
    hostname = "${ip}:22";
    fastConnection = fast;
    profiles.system.path =
      deploy-rs.lib.x86_64-linux.activate.nixos
        self.nixosConfigurations."${server}";
  };
in
{
  user = "root";
  #sshUser = "felix";
  sshUser = "root";
  nodes = {
    serverle = mkNode "serverle" "serverle.local" true;
    newton = mkNode "newton" "buehler.rocks" true;
  };
}

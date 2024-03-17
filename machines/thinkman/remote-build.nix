# enabled remote-build service
{ config, ... }:
let
  inherit (config.sops) secrets;
in
{
  sops.secrets."nixremote/ssh_key" = { };
  nix.buildMachines = [
    {
      hostName = "buehler.rocks";
      system = "x86_64-linux";
      supportedFeatures = [ "nixos-test" "benchmark" "kvm" "big-parallel" ];
      sshUser = "nixremote";
      sshKey = secrets."nixremote/ssh_key".path;
    }
  ];

  nix.distributedBuilds = true;
}

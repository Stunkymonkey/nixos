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
      supportedFeatures = [
        "benchmark"
        "kvm"
        "big-parallel"
      ];
      sshUser = "nixremote";
      sshKey = secrets."nixremote/ssh_key".path;
      maxJobs = 4;
    }
    {
      hostName = "serverle.local";
      system = "aarch64-linux";
      supportedFeatures = [ "big-parallel" ];
      sshUser = "nixremote";
      sshKey = secrets."nixremote/ssh_key".path;
      # ssh-keyscan -t ed25519 serverle.local | cut -d' ' -f2- | base64 -w0
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUgvai9OL3JpeVBUWnVkNHJiUTJNNFpINkh0djZLTzI5ei9TbisvNWx5SVI=";
      maxJobs = 2;
    }
  ];

  nix.distributedBuilds = true;
}

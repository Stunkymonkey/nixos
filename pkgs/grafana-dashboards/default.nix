{ pkgs }:

with pkgs;

let
  inherit (pkgs) stdenv fetchurl;
in

lib.makeScope pkgs.newScope (self:
let
  buildGrafanaDashboard = args: stdenv.mkDerivation (args // {
    pname = "grafana-dashboard-${args.pname}-${toString args.id}";
    inherit (args) version;
    src = fetchurl {
      url = "https://grafana.com/api/dashboards/${toString args.id}/revisions/${args.version}/download";
      hash = args.hash;
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp $src $out/${args.pname}-${toString args.id}.json
      runHook postInstall
    '';
  });
in
{
  inherit buildGrafanaDashboard;

  node-exporter = buildGrafanaDashboard {
    id = 1860;
    pname = "node-exporter-full";
    version = "31";
    hash = "sha256-QsRHsnayYRRGc+2MfhaKGYpNdH02PesnR5b50MDzHIg=";
  };

  nginx = buildGrafanaDashboard {
    id = 12708;
    pname = "nginx";
    version = "1";
    hash = "sha256-T1HqWbwt+i/We+Y2B7hcl3CijGxZF5QI38aPcXjk9y0=";
  };

  # navidrome = buildGrafanaDashboard {
  #   id = 18038;
  #   pname = "navidrome";
  #   version = "1";
  #   hash = "sha256-MU890UAEI9wrnVIC/R0HkYwFa6mJ8Y7ESAWuaSQ8FQ8=";
  # };

  loki = buildGrafanaDashboard {
    id = 14055;
    pname = "loki";
    version = "5";
    hash = "sha256-9vfUGpypFNKm9T1F12Cqh8TIl0x3jSwv2fL9HVRLt3o=";
  };

  gitea = (buildGrafanaDashboard {
    id = 13192;
    pname = "gitea";
    version = "1";
    hash = "sha256-IAaI/HvMxcWE3PGQFK8avNjgj88DgcDvkWRcDAWSejM=";
  }).overrideAttrs (self: super: {
    src = ./gitea.json; # sadly not yet updated to latest grafana
  });

  prometheus = (buildGrafanaDashboard {
    id = 3662;
    pname = "prometheus";
    version = "2";
    hash = "sha256-+nsi8/dYNvGVGV+ftfO1gSAQbO5GpZwW480T5mHMM4Q=";
  }).overrideAttrs (self: super: {
    src = ./prometheus.json; # sadly only imported dashboards work
  });
  grafana = (buildGrafanaDashboard {
    id = 3590;
    pname = "grafana";
    version = "3";
  }).overrideAttrs (self: super: {
    src = ./grafana.json; # sadly only imported dashboards work
  });
})

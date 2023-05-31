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
  node-systemd = (buildGrafanaDashboard {
    id = 1617;
    pname = "node-systemd";
    version = "1";
    hash = "sha256-MEWU5rIqlbaGu3elqdSoMZfbk67WDnH0VWuC8FqZ8v8=";
  }).overrideAttrs (self: super: {
    src = ./node-systemd.json; # sadly only imported dashboards work
  });

  nginx = buildGrafanaDashboard {
    id = 12708;
    pname = "nginx";
    version = "1";
    hash = "sha256-T1HqWbwt+i/We+Y2B7hcl3CijGxZF5QI38aPcXjk9y0=";
  };

  nextcloud = (buildGrafanaDashboard {
    id = 9632;
    pname = "nextcloud";
    version = "1";
    hash = "sha256-Z28Q/sMg3jxglkszAs83IpL8f4p9loNnTQzjc3S/SAQ=";
  }).overrideAttrs (self: super: {
    src = ./nextcloud.json; # sadly only imported dashboards work
  });

  navidrome = (buildGrafanaDashboard {
    id = 18038;
    pname = "navidrome";
    version = "1";
    hash = "sha256-MU890UAEI9wrnVIC/R0HkYwFa6mJ8Y7ESAWuaSQ8FQ8=";
  }).overrideAttrs (self: super: {
    src = ./navidrome.json; # sadly data source is not detected
  });

  loki = (buildGrafanaDashboard {
    id = 13407;
    pname = "loki";
    version = "1";
    hash = "sha256-1sxTDSEwi2O/Ce+rWqqhMvsYEJeELBfkb9W2R6cDjcU=";
  }).overrideAttrs (self: super: {
    src = ./loki.json; # sadly not yet updated to latest grafana
  });

  alertmanager = buildGrafanaDashboard {
    id = 9578;
    pname = "alertmanager";
    version = "4";
    hash = "sha256-/scCKBKqTjRKKImIrEYLBKGweOUnkx+QsD5yLfdXW5o=";
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

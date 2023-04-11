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
})

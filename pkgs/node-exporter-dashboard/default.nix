{ stdenv
, fetchFromGitHub
, lib
}:
stdenv.mkDerivation {
  version = "unstable-2023-03-30";
  pname = "grafana-dashboard-node-exporter";

  dontBuild = true;

  src = fetchFromGitHub {
    owner = "rfrail3";
    repo = "grafana-dashboards";
    rev = "1e67d6fc6adf18c721d2eb85a39fd270cfcb7b10";
    hash = "sha256-S3+RtUId+f7MdoakcZkhw069Q8IupEWJLSwlNPzxZvM=";
  };

  installPhase = ''
    mkdir -p $out
    cp prometheus/node-exporter-full.json $out/node-exporter-full.json
  '';

  meta = {
    description = "grafana dashboard for node exporter";
    homepage = "https://github.com/rfrail3/grafana-dashboards";
    license = lib.licenses.lgpl3Only;
  };
}

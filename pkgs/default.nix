final: _prev: {
  homer = final.callPackage ./homer { };
  grafana-dashboards = final.callPackage ./grafana-dashboards { };
}

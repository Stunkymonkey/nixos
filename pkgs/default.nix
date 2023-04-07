final: prev:
{
  homer = final.callPackage ./homer { };
  node-exporter-dashboard = final.callPackage ./node-exporter-dashboard { };
}

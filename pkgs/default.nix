#{ pkgs }:
#pkgs.lib.makeScope pkgs.newScope (pkgs: {
#  homarr = pkgs.callPackage ./homarr { };
#})
final: prev:
{
  homer = final.callPackage ./homer { };
}

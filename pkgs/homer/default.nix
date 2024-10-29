{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "24.10.2";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-V4E/KLOzfiCMwdQrXzab2VzjuB0TYpocoYhdUVt4g78=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

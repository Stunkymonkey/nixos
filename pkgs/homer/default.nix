{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "23.02.1";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-cCr2Qc534vbzxJp905cFEa+KHIpMMTIzXnZ+qunmkz0=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

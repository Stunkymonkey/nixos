{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "24.04.1";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-BWQMBQn/bnRQdhJpgn9sIeiybdzT7c9c9h9toNGx48k=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

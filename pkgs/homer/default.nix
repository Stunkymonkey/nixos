{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "24.10.1";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-UWRFiWkZi/1aHkf+hgXdnoVYb6bCBPPrk7DJAKla/B4=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

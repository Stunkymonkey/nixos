{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "22.07.2";

  src = fetchzip {
    urls = [
      "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip"
    ];
    sha256 = "sha256-rmCqjWn7bbTESmOHTO5H7YVyZzny617pI0VdSlsqYGI=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

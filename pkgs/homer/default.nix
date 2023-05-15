{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "23.05.1";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-pYVbJ+7i4K3QWRYxVd2tu/aQ3FgfhGH6VM2ZRils53c=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

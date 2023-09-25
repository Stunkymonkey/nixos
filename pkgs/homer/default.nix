{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "23.09.1";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-l6bfNzbW2uNaAVdBztG6B8dFnrRjQGBUCp9g+VoS1II=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

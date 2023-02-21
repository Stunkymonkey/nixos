{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "23.02.2";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-/YUuv5kctjVbtoo0bhSwTKc5NFpkA7mwCllwESl/bVI=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

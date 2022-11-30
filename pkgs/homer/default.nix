{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "22.11.2";

  src = fetchzip {
    urls = [
      "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip"
    ];
    sha256 = "sha256-kqD7hm4W51MTSxiYd+6O8Dbnf3c3E60av7x0HYVcAPQ=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

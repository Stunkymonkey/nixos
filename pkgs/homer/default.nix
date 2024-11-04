{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "24.11.1";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-rp9NyUfywKXSt9SRMJI6QOh4IcHsnpiBM/NGM4TLFaE=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

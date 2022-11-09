{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "22.11.1";

  src = fetchzip {
    urls = [
      "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip"
    ];
    sha256 = "sha256-5W+bnPxXAv+svg3zrsiNTjZWrUuR39qKCnGGYY6pBjg=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

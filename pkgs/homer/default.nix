{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "23.10.1";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-KUEqrjO9LAoigZsQGLy5JrtsXx+HDXaz4Y4Vpba0uNw=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

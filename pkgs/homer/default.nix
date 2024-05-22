{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "homer";
  version = "24.05.1";

  src = fetchzip {
    url = "https://github.com/bastienwirtz/homer/releases/download/v${version}/homer.zip";
    hash = "sha256-2CnSDikhB903gnDbWPF4hwoih6B0x4KQs9qAIcrUUgg=";
    stripRoot = false;
  };

  installPhase = ''
    cp -r $src $out/
  '';
  sourceRoot = ".";
}

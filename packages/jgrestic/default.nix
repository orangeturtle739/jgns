{ stdenv, nixFlakes, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "jgrestic";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "orangeturtle739";
    repo = "jgrestic";
    rev = "af1389bfba4fb8242628a7c2af6ed4fb49ab8363";
    sha256 = "MWHosfpdPz0NAMJoAsxOkM4xlh4A9ClRigjDqt8Lmj4=";
  };
  requiredSystemFeatures = [ "recursive-nix" "nix-command" ];

  nativeBuildInputs = [ nixFlakes ];

  doConfigure = false;
  buildPhase = ''
    echo haha
  '';
  installPhase = ''
    echo haha
    ls
    mkdir kindofhome
    export HOME=$(pwd)/kindofhome
    pkg=$(nix --experimental-features "nix-command flakes" build)
    cp -r $pkg $out
  '';
}

{ stdenv, fetchFromGitHub, makeWrapper, rofi, xdotool, xsel, jq, coreutils }:
stdenv.mkDerivation rec {
  pname = "splatmoji";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "cspeterson";
    repo = pname;
    rev = "v${version}";
    sha256 = "fsZ8FhLP3vAalRJWUEi/0fe0DlwAz5zZeRZqAuwgv/U=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin/
    cp -a data importers lib splatmoji* $out/bin
    wrapProgram $out/bin/splatmoji --set PATH ${
      stdenv.lib.makeBinPath [ rofi xdotool xsel jq coreutils ]
    }
  '';
}

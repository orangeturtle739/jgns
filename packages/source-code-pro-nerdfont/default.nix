# See:
# https://github.com/NixOS/nixpkgs/pull/63079
# https://github.com/NixOS/nixpkgs/issues/47921
# Nerd fonts is 2.0 GB, so just download the font we need.
{ stdenv, lib, fetchurl, unzip }:
stdenv.mkDerivation rec {
  version = "2.2.2";
  pname = "source-code-pro-nerdfont";
  src = fetchurl {
    url =
      "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/SourceCodePro.zip";
    sha256 = "pzZEjwTHO97+/DVsAkpdklDsCGoGIchBefxEWHZQxzE=";
  };
  nativeBuildInputs = [ unzip ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/share/fonts/source-code-pro-nerdfont
    unzip -j $src -d $out/share/fonts/source-code-pro-nerdfont
  '';
}

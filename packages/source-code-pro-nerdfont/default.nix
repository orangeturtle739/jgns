# See:
# https://github.com/NixOS/nixpkgs/pull/63079
# https://github.com/NixOS/nixpkgs/issues/47921
# Nerd fonts is 2.0 GB, so just download the font we need.
{ lib, fetchzip }:
let version = "2.1.0";
in fetchzip {
  name = "source-code-pro-nerdfont-${version}";

  url =
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/SourceCodePro.zip";

  postFetch = ''
    mkdir -p $out/share/fonts/source-code-pro-nerdfont
    unzip -j $downloadedFile -d $out/share/fonts/source-code-pro-nerdfont
  '';

  sha256 = "13hgqmqb3sxsl9zwmz048c414fqfa1v066ji08airiw42jg0xz6d";
}

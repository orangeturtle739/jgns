{ lib, fetchFromGitHub, rustPlatform }:
# https://github.com/mvertescher/emoji-fzf
rustPlatform.buildRustPackage rec {
  name = "emoji-fzf";

  src = fetchFromGitHub {
    owner = "mvertescher";
    repo = name;
    rev = "ae66caa0032b884380dd4ff6ac311fd080a2db49";
    sha256 = lib.fakeSha256;
  };

  cargoSha256 = "1T9PaLpotchq/XsB/0TiS3Gn7+skwlfXZHExiEu1spg=";
  buildInputs = [ pkg-config udev ];

  meta = with lib; {
    description =
      "Keyboard keycode mapping utility for Linux supporting layered configuration";
    homepage = "https://github.com/samvel1024/kbct";
  };
}


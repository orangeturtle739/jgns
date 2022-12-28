{ lib, fetchFromGitHub, rustPlatform, udev, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "kbct";
  version = "0.1.0+beta";

  src = fetchFromGitHub {
    owner = "samvel1024";
    repo = pname;
    rev = "7e68f139fe1ecfdc01a437cefc7199232a349f4e";
    sha256 = "H4okrIZq5MrKIeE7jfQEH6JikMR9U7iKyFtrT+pnxU4=";
  };

  cargoSha256 = "1T9PaLpotchq/XsB/0TiS3Gn7+skwlfXZHExiEu1spg=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  meta = with lib; {
    description =
      "Keyboard keycode mapping utility for Linux supporting layered configuration";
    homepage = "https://github.com/samvel1024/kbct";
  };
}

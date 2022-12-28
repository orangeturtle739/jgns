{ lib, fetchFromGitHub, rustPlatform, wayland, pkg-config, cmake }:

rustPlatform.buildRustPackage rec {
  pname = "yofi";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "l4l";
    repo = pname;
    rev = version;
    sha256 = "MDxlNLTtOXtz16bBp3Z5RqCaIBM98eZ3c/FsyjE4Wcw=";
  };

  cargoSha256 = "YpDMCtVASBS2yJAOEzInlsGwYvuyWRYm/Q7YVv760ao=";
  nativeBuildInputs = [ pkg-config cmake ];
  buildInputs = [ wayland ];

  meta = with lib; {
    description = "yofi is a minimalistic menu for wayland";
    homepage = "https://github.com/l4l/yofi";
  };
}

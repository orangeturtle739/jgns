{ buildGoPackage, fetchFromGitHub }:
buildGoPackage rec {
  name = "pms";
  goPackagePath = "github.com/ambientsound/pms";
  src = fetchFromGitHub {
    owner = "ambientsound";
    repo = "pms";
    rev = "cae1f02928cc8a3461f6fdba4165dd35c8b85b6b";
    sha256 = "1p5sq40cf6pvl2qwm7bl98rss2bq4m1dhpg1ci851j0v5gfd1fk2";
  };
  goDeps = ./deps.nix;
}

{ buildGoPackage, fetchFromGitHub, pkgconfig, gobject-introspection, cairo
, pango, gtk3 }:
buildGoPackage rec {
  pname = "ymuse";
  version = "0.7";
  goPackagePath = "github.com/yktoo/ymuse";
  src = fetchFromGitHub {
    owner = "orangeturtle739";
    repo = "ymuse";
    rev = "d7b2c5f2a98b5c38097366a48032a4171ff9ba27";
    sha256 = "0iwjgyrsy8zjw6zgkm6zi0ck4wqd37byk7hbjj3hpqb5nf7y0mf3";
  };
  preBuild = ''
    patchShebangs ./
    go generate ./...
  '';
  buildInputs = [ pkgconfig gobject-introspection cairo pango gtk3 ];
  goDeps = ./deps.nix;
}

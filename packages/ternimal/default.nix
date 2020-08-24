{ stdenv, fetchFromGitHub, rustc }:
stdenv.mkDerivation {
  name = "ternimal";
  src = fetchFromGitHub {
    owner = "p-e-w";
    repo = "ternimal";
    rev = "e7953b4f80e514899e0920f0e36bb3141b685122";
    sha256 = "0wx39hvd6d0dcpnaiwyv1m13kpk5svmr9a48zm1gkdnj3g0nx35q";
  };
  buildPhase = ''
    ${rustc}/bin/rustc -O ternimal.rs
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ternimal $out/bin
  '';
}

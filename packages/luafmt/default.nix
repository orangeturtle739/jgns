{ stdenv, luaPackages, fetchFromGitHub, makeWrapper }:
let luaversion = luaPackages.lua.luaversion;
in luaPackages.toLuaModule (stdenv.mkDerivation rec {
  name = "luafmt";

  src = fetchFromGitHub {
    owner = "orangeturtle739";
    repo = "luafmt";
    rev = "2aefa3bfc2b250113c300c24085c62876dc329e0";
    sha256 = "0ha200c5wmw463395f0xwxz7y9hdyilqq2a73h207jgmhiq5vh7z";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ luaPackages.lua ];

  installPhase = ''
    mkdir -p $out/lib/lua/${luaversion}/
    cp -r . $out/lib/lua/${luaversion}/luafmt/
    makeWrapper ${luaPackages.lua}/bin/lua $out/bin/luafmt --add-flags $out/lib/lua/${luaversion}/luafmt/luafmt.lua
  '';
})

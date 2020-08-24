{ stdenv, luaPackages, fetchFromGitHub }:
let luaversion = luaPackages.lua.luaversion;
in luaPackages.toLuaModule (stdenv.mkDerivation rec {
  name = "lain";

  src = fetchFromGitHub {
    owner = "orangeturtle739";
    repo = "lain";
    rev = "9d18e0d973c35afa0095e0c9357369269652b5d0";
    sha256 = "1hq9n96qbibwi94lpx7b4r7md77z9asjjpgirjlmj9xmghmiy98x";
  };

  buildInputs = [ luaPackages.lua ];

  installPhase = ''
    mkdir -p $out/lib/lua/${luaversion}/
    cp -r . $out/lib/lua/${luaversion}/lain/
    printf "package.path = '$out/lib/lua/${luaversion}/?/init.lua;' ..  package.path\nreturn require((...) .. '.init')\n" > $out/lib/lua/${luaversion}/lain.lua
  '';
})

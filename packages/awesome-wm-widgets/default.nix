{ stdenv, luaPackages, fetchFromGitHub }:
let luaversion = luaPackages.lua.luaversion;
in luaPackages.toLuaModule (stdenv.mkDerivation rec {
  name = "awesome-wm-widgets";

  src = fetchFromGitHub {
    owner = "orangeturtle739";
    repo = "awesome-wm-widgets";
    rev = "0e4bbcf1a974f6f5c0369c305268a6ecb1e9d57a";
    sha256 = "0w42wi365w7ai40f0m8yjbbnfca5nk2xh024byjpbklplziysy06";
  };

  buildInputs = [ luaPackages.lua ];

  installPhase = ''
    mkdir -p $out/lib/lua/${luaversion}/
    cp -r . $out/lib/lua/${luaversion}/awesome-wm-widgets/
    printf "package.path = '$out/lib/lua/${luaversion}/?/init.lua;' ..  package.path\nreturn require((...) .. '.init')\n" > $out/lib/lua/${luaversion}/awesome-wm-widgets.lua
  '';
})


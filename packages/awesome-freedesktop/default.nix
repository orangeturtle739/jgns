{ stdenv, luaPackages, fetchFromGitHub }:
let luaversion = luaPackages.lua.luaversion;
in luaPackages.toLuaModule (stdenv.mkDerivation rec {
  name = "awesome-freedesktop";

  src = fetchFromGitHub {
    owner = "lcpz";
    repo = "awesome-freedesktop";
    rev = "dc0a18c2c35a0cf888b5968115df810b90db91cf";
    sha256 = "0nq7hi75xgiw3bknq6rhfqj6454q607k28riacy5hl9h94y7c6j9";
  };

  buildInputs = [ luaPackages.lua ];

  installPhase = ''
    mkdir -p $out/lib/lua/${luaversion}/
    cp -r . $out/lib/lua/${luaversion}/freedesktop/
    printf "package.path = '$out/lib/lua/${luaversion}/?/init.lua;' ..  package.path\nreturn require((...) .. '.init')\n" > $out/lib/lua/${luaversion}/freedesktop.lua
  '';
})


{ python3Packages, libmikmod, fetchFromGitHub }:

let
  patched_pygame = python3Packages.pygame.override (pygameOld: {
    SDL_mixer = pygameOld.SDL_mixer.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ libmikmod ];
      configureFlags = old.configureFlags ++ [ "--disable-music-mod-shared" ];
    });
  });
in python3Packages.buildPythonApplication rec {
  pname = "solarwolf";
  version = "7d09103f10d6b00f5ac71dcffdd66b90ce74def1";
  src = fetchFromGitHub {
    owner = "limburgher";
    repo = "solarwolf";
    rev = "7d09103f10d6b00f5ac71dcffdd66b90ce74def1";
    sha256 = "104c514nvh46kh8jrjqyz4knk3xpxq01wg4c5xl3hvxa95dyl3vx";
  };
  dontUseSetuptoolsCheck = true;
  propagatedBuildInputs = [ python3Packages.pytest patched_pygame ];
}


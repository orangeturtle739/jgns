{ lib, python3Packages, libmikmod, fetchFromGitHub }:
python3Packages.buildPythonApplication rec {
  pname = "solarwolf";
  version = "40bc2292b42100be3c442d30bbfc096c3326e2e1";
  src = fetchFromGitHub {
    owner = "pygame";
    repo = "solarwolf";
    rev = "40bc2292b42100be3c442d30bbfc096c3326e2e1";
    sha256 = "bgKb57XjnbDxN3BD7b8HbAx9WEIebMmJCxKwsIwzxkE=";
  };
  dontUseSetuptoolsCheck = true;
  pyproject = true;
  build-system = [ python3Packages.setuptools ];
  propagatedBuildInputs = with python3Packages; [ pytest pygame ];
}


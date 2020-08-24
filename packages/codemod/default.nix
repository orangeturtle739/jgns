{ python3Packages, fetchFromGitHub }:
python3Packages.buildPythonApplication rec {
  pname = "codemod";
  version = "41d6eabad7b055a83923150efd5518813831c9a5";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "codemod";
    rev = "41d6eabad7b055a83923150efd5518813831c9a5";
    sha256 = "0bivzjdlcx63xir3g63dyf6qla76fkw7b71xfsdkaawcqxzg2lgz";
  };
  propagatedBuildInputs = with python3Packages; [ pytest flake8 ];
}

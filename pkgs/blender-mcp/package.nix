{
  lib,
  python3Packages,
  fetchgit,
}:

python3Packages.buildPythonApplication rec {
  pname = "blender-mcp";
  version = "1.0.2";
  pyproject = true;

  src = fetchgit {
    url = "https://projects.blender.org/lab/blender_mcp.git";
    rev = "v${version}";
    hash = "sha256-PjZnKBSls6j6F4r3WK/doofdMDUZO3S573Y8SHCrDqg=";
  };

  # The repo holds the add-on, the chat client and the server; only mcp/ is a
  # Python package. Gitea serves no usable release tarball (its archive
  # endpoint 403s), hence fetchgit rather than fetchFromGitea.
  sourceRoot = "${src.name}/mcp";

  build-system = [ python3Packages.setuptools ];

  # pyproject asks for mcp[cli], but nothing here imports mcp.cli — the extra
  # would only add typer and python-dotenv.
  dependencies = with python3Packages; [
    docutils
    mcp
    pyyaml
  ];

  pythonImportsCheck = [ "blmcp" ];

  meta = {
    description = "MCP server for Blender, talking to the Blender Lab add-on over TCP";
    homepage = "https://www.blender.org/lab/mcp-server/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "blender-mcp";
  };
}

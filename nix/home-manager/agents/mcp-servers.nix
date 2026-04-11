# Shared MCP server definitions for Claude Code and Codex CLI
# Used by claude-code.nix and codex-cli.nix
{
  pkgs,
  inputs,
  homeDir,
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
  unstablePython = unstablePkgs.python3Packages;

  # Servers managed by mcp-servers-nix (pinned Nix packages)
  nixServers =
    (inputs.mcp-servers-nix.lib.evalModule pkgs {
      programs = {
        context7.enable = true;
      };
    }).config.settings.servers;

  awsDocumentationMcp = unstablePython.buildPythonApplication rec {
    pname = "awslabs-aws-documentation-mcp-server";
    version = "1.1.20";
    pyproject = true;
    src = unstablePkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/source/a/awslabs.aws-documentation-mcp-server/awslabs_aws_documentation_mcp_server-${version}.tar.gz";
      hash = "sha256-4IW1onEgeA17edXbtuPXc72Yt6Yg3EhPGoWOThPdPlg=";
    };
    build-system = [ unstablePython.hatchling ];
    dependencies = with unstablePython; [
      beautifulsoup4
      httpx
      loguru
      markdownify
      mcp
      pydantic
    ];
    pythonImportsCheck = [ "awslabs.aws_documentation_mcp_server" ];
  };

  # Servers not yet provided by mcp-servers-nix, packaged here as pinned store executables
  manualServers = {
    awslabs-aws-documentation-mcp-server = {
      command = "${awsDocumentationMcp}/bin/awslabs.aws-documentation-mcp-server";
    };
    dbt = {
      command = "${pkgs.uv}/bin/uvx";
      args = [ "dbt-mcp" ];
      env = {
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];
      };
    };
    drawio = {
      command = "${homeDir}/.local/bin/drawio-mcp";
    };
  };
in
nixServers // manualServers

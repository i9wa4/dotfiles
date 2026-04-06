# Shared MCP server definitions for Claude Code and Codex CLI
# Used by claude-code.nix and codex-cli.nix
{
  pkgs,
  inputs,
  homeDir,
  nodejsPackage,
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

  drawioMcp = pkgs.buildNpmPackage {
    pname = "drawio-mcp";
    version = "1.1.8";
    src = inputs.drawio-mcp;
    sourceRoot = "source/mcp-tool-server";
    npmDepsHash = "sha256-ufgxe7zCTUU06IROtrTd5+lrqXHaNNqip8Oe/ZQsZ6Q=";
    dontNpmBuild = true;
    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib/node_modules/@drawio/mcp" "$out/bin"
      cp -r . "$out/lib/node_modules/@drawio/mcp"
      makeWrapper ${nodejsPackage}/bin/node "$out/bin/drawio-mcp" \
        --add-flags "$out/lib/node_modules/@drawio/mcp/src/index.js"
      runHook postInstall
    '';
  };

  # Servers not yet provided by mcp-servers-nix, packaged here as pinned store executables
  manualServers = {
    awslabs-aws-documentation-mcp-server = {
      command = "${awsDocumentationMcp}/bin/awslabs.aws-documentation-mcp-server";
    };
    drawio = {
      command = "${drawioMcp}/bin/drawio-mcp";
    };
  };
in
nixServers // manualServers

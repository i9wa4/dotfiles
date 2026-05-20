# Resolved install contract for native agent files and shared skill targets.
# Edit subagents/*.md for reviewer agent source. Claude installs those
# Markdown files directly; Codex gets generated runtime TOML from the same
# Markdown source.
{
  config,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  claudeAgentsSource = ../subagents;
  codexAgentConverter = pkgs.writeText "codex-agent-md-to-toml.py" ''
    import json
    import sys
    from pathlib import Path


    source_dir = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])


    def split_frontmatter(path):
        text = path.read_text(encoding="utf-8")
        if not text.startswith("---\n"):
            raise ValueError(f"{path}: missing opening frontmatter marker")

        marker = "\n---\n"
        end = text.find(marker, 4)
        if end == -1:
            raise ValueError(f"{path}: missing closing frontmatter marker")

        frontmatter = text[4:end]
        body = text[end + len(marker) :]
        if body.startswith("\n"):
            body = body[1:]
        return frontmatter, body


    def parse_frontmatter(frontmatter, path):
        values = {}
        for line in frontmatter.splitlines():
            if not line.strip():
                continue
            key, sep, value = line.partition(":")
            if sep != ":":
                raise ValueError(f"{path}: unsupported frontmatter line: {line}")
            values[key.strip()] = value.strip()

        for required in ["name", "description"]:
            if not values.get(required):
                raise ValueError(f"{path}: missing required frontmatter field: {required}")
        return values


    def toml_string(value):
        return json.dumps(value, ensure_ascii=False)


    for source in sorted(source_dir.glob("*.md")):
        frontmatter, body = split_frontmatter(source)
        values = parse_frontmatter(frontmatter, source)
        if values["name"] != source.stem:
            raise ValueError(
                f"{source}: frontmatter name {values['name']!r} must match file stem"
            )
        target = out_dir / f"{source.stem}.toml"
        target.write_text(
            "\n".join(
                [
                    f"name = {toml_string(values['name'])}",
                    f"description = {toml_string(values['description'])}",
                    f"developer_instructions = {toml_string(body)}",
                    "",
                ]
            ),
            encoding="utf-8",
        )
  '';
  codexAgentsSource = pkgs.runCommand "codex-agents-from-markdown" { } ''
    set -eu
    mkdir -p "$out"
    ${pkgs.python3}/bin/python3 ${codexAgentConverter} ${claudeAgentsSource} "$out"
  '';
in
{
  claude = {
    agents = {
      target = ".claude/agents";
      source = claudeAgentsSource;
    };

    skills = {
      dest = "${homeDir}/.claude/skills";
      structure = "symlink-tree";
    };
  };

  codex = {
    agents = {
      target = ".codex/agents";
      source = codexAgentsSource;
    };

    skills = {
      dest = "${homeDir}/.codex/skills";
      structure = "symlink-tree";
    };
  };

  skills = {
    sources = { };
  };
}

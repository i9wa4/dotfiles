# Resolved install contract for native agent files and shared skill targets.
# Edit subagents/*.md for reviewer prompt bodies and subagents/metadata.nix for
# per-runtime model/effort defaults. Claude and Codex agent files are generated
# from those shared sources.
{
  config,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  subagentPromptSource = ../subagents;
  subagentMetadata = import ../subagents/metadata.nix;
  subagentMetadataJson = pkgs.writeText "subagent-metadata.json" (builtins.toJSON subagentMetadata);
  agentRenderer = pkgs.writeText "render-native-agents.py" ''
    import json
    import sys
    from pathlib import Path


    source_dir = Path(sys.argv[1])
    metadata_path = Path(sys.argv[2])
    claude_out_dir = Path(sys.argv[3])
    codex_out_dir = Path(sys.argv[4])


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


    def yaml_plain_scalar(value):
        if not value or value.strip() != value or "\n" in value:
            return toml_string(value)

        safe_chars = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")
        if all(char in safe_chars for char in value):
            return value

        return toml_string(value)


    def toml_multiline_literal(value, context):
        delimiter = chr(39) * 3
        if delimiter in value:
            raise ValueError(
                f"{context}: cannot render TOML multiline literal containing triple single quotes"
            )

        return delimiter + "\n" + value + delimiter


    def validate_mapping(mapping, *, required, allowed, context):
        missing = sorted(required - set(mapping))
        if missing:
            raise ValueError(f"{context}: missing required fields: {', '.join(missing)}")

        extra = sorted(set(mapping) - allowed)
        if extra:
            raise ValueError(f"{context}: unsupported fields: {', '.join(extra)}")


    def validate_optional_string(value, context):
        if value is not None and not isinstance(value, str):
            raise ValueError(f"{context}: expected string or null")


    def render_claude_agent(source, values, body, metadata):
        claude = metadata["claude"]
        frontmatter = [
            "---",
            f"name: {toml_string(values['name'])}",
            f"description: {toml_string(values['description'])}",
        ]
        if claude.get("model") is not None:
            frontmatter.append(f"model: {yaml_plain_scalar(claude['model'])}")
        if claude.get("effort") is not None:
            frontmatter.append(f"effort: {yaml_plain_scalar(claude['effort'])}")
        frontmatter.extend(["---", "", body])

        target = claude_out_dir / source.name
        target.write_text("\n".join(frontmatter), encoding="utf-8")


    def render_codex_agent(source, values, body, metadata):
        codex = metadata["codex"]
        lines = [
            f"name = {toml_string(values['name'])}",
            f"description = {toml_string(values['description'])}",
        ]
        if codex.get("model") is not None:
            lines.append(f"model = {toml_string(codex['model'])}")
        if codex.get("modelReasoningEffort") is not None:
            lines.append(
                "model_reasoning_effort = "
                f"{toml_string(codex['modelReasoningEffort'])}"
            )
        lines.extend(
            [
                "developer_instructions = "
                f"{toml_multiline_literal(body, f'{source}: developer_instructions')}",
                "",
            ]
        )

        target = codex_out_dir / f"{source.stem}.toml"
        target.write_text("\n".join(lines), encoding="utf-8")


    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    sources = sorted(source_dir.glob("*.md"))
    source_names = {source.stem for source in sources}
    metadata_names = set(metadata)

    missing_metadata = sorted(source_names - metadata_names)
    if missing_metadata:
        raise ValueError(
            "missing subagent metadata for: " + ", ".join(missing_metadata)
        )

    extra_metadata = sorted(metadata_names - source_names)
    if extra_metadata:
        raise ValueError(
            "metadata without matching subagent Markdown: " + ", ".join(extra_metadata)
        )

    for source in sorted(source_dir.glob("*.md")):
        frontmatter, body = split_frontmatter(source)
        values = parse_frontmatter(frontmatter, source)
        if values["name"] != source.stem:
            raise ValueError(
                f"{source}: frontmatter name {values['name']!r} must match file stem"
            )
        source_metadata = metadata[source.stem]
        validate_mapping(
            source_metadata,
            required={"claude", "codex"},
            allowed={"claude", "codex"},
            context=f"{source}: metadata",
        )
        validate_mapping(
            source_metadata["claude"],
            required=set(),
            allowed={"model", "effort"},
            context=f"{source}: claude metadata",
        )
        validate_mapping(
            source_metadata["codex"],
            required=set(),
            allowed={"model", "modelReasoningEffort"},
            context=f"{source}: codex metadata",
        )
        validate_optional_string(
            source_metadata["claude"].get("model"),
            f"{source}: claude.model",
        )
        validate_optional_string(
            source_metadata["claude"].get("effort"),
            f"{source}: claude.effort",
        )
        validate_optional_string(
            source_metadata["codex"].get("model"),
            f"{source}: codex.model",
        )
        validate_optional_string(
            source_metadata["codex"].get("modelReasoningEffort"),
            f"{source}: codex.modelReasoningEffort",
        )

        render_claude_agent(source, values, body, source_metadata)
        render_codex_agent(source, values, body, source_metadata)
  '';
  renderedAgentsSource = pkgs.runCommand "native-agents-from-markdown" { } ''
    set -eu
    mkdir -p "$out/claude" "$out/codex"
    ${pkgs.python3}/bin/python3 ${agentRenderer} \
      ${subagentPromptSource} \
      ${subagentMetadataJson} \
      "$out/claude" \
      "$out/codex"
  '';
  claudeAgentsSource = "${renderedAgentsSource}/claude";
  codexAgentsSource = "${renderedAgentsSource}/codex";
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

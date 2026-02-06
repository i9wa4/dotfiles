"""
Skill Initializer - Creates a new skill from template

Usage:
    python init_skill.py <skill-name> --path <path>

Examples:
    python init_skill.py my-new-skill --path skills/
"""

import sys
from pathlib import Path

SKILL_TEMPLATE = """---
name: {skill_name}
description: |
  TODO: Explain what the skill does and when to use it.
  Include triggers and scenarios.
---

# {skill_title}

## Overview

TODO: 1-2 sentences explaining what this skill enables.

## Usage

TODO: Add usage instructions, examples, and workflows.

## Resources

Optional directories:
- scripts/: Executable code (Python/Bash)
- references/: Documentation loaded into context
- assets/: Files used in output (templates, images)

Delete unused directories.
"""


def title_case_skill_name(skill_name):
    """Convert hyphenated skill name to Title Case."""
    return " ".join(word.capitalize() for word in skill_name.split("-"))


def init_skill(skill_name, path):
    """Initialize a new skill directory with template SKILL.md."""
    skill_dir = Path(path).resolve() / skill_name

    if skill_dir.exists():
        print(f"Error: Skill directory already exists: {skill_dir}")
        return None

    try:
        skill_dir.mkdir(parents=True, exist_ok=False)
        print(f"Created skill directory: {skill_dir}")
    except Exception as e:
        print(f"Error creating directory: {e}")
        return None

    skill_title = title_case_skill_name(skill_name)
    skill_content = SKILL_TEMPLATE.format(
        skill_name=skill_name, skill_title=skill_title
    )

    skill_md_path = skill_dir / "SKILL.md"
    try:
        skill_md_path.write_text(skill_content)
        print("Created SKILL.md")
    except Exception as e:
        print(f"Error creating SKILL.md: {e}")
        return None

    print(f"\nSkill '{skill_name}' initialized at {skill_dir}")
    print("\nNext steps:")
    print("1. Edit SKILL.md to complete TODOs")
    print("2. Add scripts/, references/, or assets/ as needed")

    return skill_dir


def main():
    if len(sys.argv) < 4 or sys.argv[2] != "--path":
        print("Usage: python init_skill.py <skill-name> --path <path>")
        print("\nExamples:")
        print("  python init_skill.py my-skill --path skills/")
        sys.exit(1)

    skill_name = sys.argv[1]
    path = sys.argv[3]

    print(f"Initializing skill: {skill_name}")
    print(f"Location: {path}\n")

    result = init_skill(skill_name, path)
    sys.exit(0 if result else 1)


if __name__ == "__main__":
    main()

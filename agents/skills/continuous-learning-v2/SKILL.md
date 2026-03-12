---
name: continuous-learning-v2
description: |
  Instinct-based learning system that observes sessions via hooks, creates atomic instincts with confidence scoring, and evolves them into skills/commands/agents. v2.1 adds project-scoped instincts to prevent cross-project contamination.
  Use when:
  - Setting up or configuring the instinct learning system
  - Reviewing how observation hooks or instinct analysis works
  - Managing project-scoped vs global instincts
  - Promoting instincts from project to global scope
  - Importing or exporting instincts
origin: ECC
version: 2.1.0
source: https://github.com/affaan-m/everything-claude-code/tree/main/skills/continuous-learning-v2
---

# Continuous Learning v2.1 - Instinct-Based Architecture

An advanced learning system that turns Claude Code sessions into reusable knowledge through atomic "instincts" -- small learned behaviors with confidence scoring.

**v2.1** adds **project-scoped instincts** -- React patterns stay in your React project, Python conventions stay in your Python project, and universal patterns (like "always validate input") are shared globally.

## Architecture Overview

### Hook Layer (Nix-managed)

Observation hooks are registered via `nix/home-manager/modules/claude-code.nix` and deployed by `home-manager switch`. The hook scripts live at:

- `agents/scripts/claude-observe.sh` -- PreToolUse/PostToolUse observer
- `agents/scripts/claude-detect-project.sh` -- project detection helper (sourced by observer)

These are NOT inside this skill directory because they are shared infrastructure managed by Nix.

### CLI Layer (this skill)

The instinct CLI lives at:

```text
${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py
```

Use `/instinct-status` and `/evolve` skills for the most common operations. For other commands, run the CLI directly:

```bash
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py <command>
```

## The Instinct Model

An instinct is a small learned behavior:

```yaml
---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.7
domain: "code-style"
source: "session-observation"
scope: project
project_id: "a1b2c3d4e5f6"
project_name: "my-react-app"
---

# Prefer Functional Style

## Action
Use functional patterns over classes when appropriate.

## Evidence
- Observed 5 instances of functional pattern preference
- User corrected class-based approach to functional on 2025-01-15
```

**Properties:**

- **Atomic** -- one trigger, one action
- **Confidence-weighted** -- 0.3 = tentative, 0.9 = near certain
- **Domain-tagged** -- code-style, testing, git, debugging, workflow, etc.
- **Evidence-backed** -- tracks what observations created it
- **Scope-aware** -- `project` (default) or `global`

## How It Works

```text
Session Activity (in a git repo)
      |
      | Hooks capture prompts + tool use (100% reliable)
      | + detect project context (git remote / repo path)
      v
+---------------------------------------------+
|  projects/<project-hash>/observations.jsonl  |
|   (prompts, tool calls, outcomes, project)   |
+---------------------------------------------+
      |
      | Observer agent reads (background, Haiku)
      v
+---------------------------------------------+
|          PATTERN DETECTION                   |
|   * User corrections -> instinct             |
|   * Error resolutions -> instinct            |
|   * Repeated workflows -> instinct           |
|   * Scope decision: project or global?       |
+---------------------------------------------+
      |
      | Creates/updates
      v
+---------------------------------------------+
|  projects/<project-hash>/instincts/personal/ |
|   * prefer-functional.yaml (0.7) [project]   |
|   * use-react-hooks.yaml (0.9) [project]     |
+---------------------------------------------+
|  instincts/personal/  (GLOBAL)               |
|   * always-validate-input.yaml (0.85) [global]|
|   * grep-before-edit.yaml (0.6) [global]     |
+---------------------------------------------+
      |
      | /evolve clusters + /promote
      v
+---------------------------------------------+
|  projects/<hash>/evolved/ (project-scoped)   |
|  evolved/ (global)                           |
|   * commands/new-feature.md                  |
|   * skills/testing-workflow.md               |
|   * agents/refactor-specialist.md            |
+---------------------------------------------+
```

## Project Detection

The system automatically detects your current project:

1. **`CLAUDE_PROJECT_DIR` env var** (highest priority)
2. **`git remote get-url origin`** -- hashed to create a portable project ID (same repo on different machines gets the same ID)
3. **`git rev-parse --show-toplevel`** -- fallback using repo path (machine-specific)
4. **Global fallback** -- if no project is detected, instincts go to global scope

Each project gets a 12-character hash ID (e.g., `a1b2c3d4e5f6`). A registry file at `projects.json` maps IDs to human-readable names.

## CLI Commands

| Command         | Description                                                    |
| --------------- | -------------------------------------------------------------- |
| `status`        | Show all instincts (project-scoped + global) with confidence   |
| `evolve`        | Cluster related instincts into skills/commands, suggest promos |
| `export`        | Export instincts (filterable by scope/domain)                  |
| `import <file>` | Import instincts with scope control                            |
| `promote [id]`  | Promote project instincts to global scope                      |
| `projects`      | List all known projects and their instinct counts              |

Usage:

```bash
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py status
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py evolve
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py promote --dry-run
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py projects
```

## Configuration

Edit `config.json` (in this skill directory) to control the background observer:

```json
{
  "version": "2.1",
  "observer": {
    "enabled": false,
    "run_interval_minutes": 5,
    "min_observations_to_analyze": 20
  }
}
```

| Key                                    | Default | Description                                  |
| -------------------------------------- | ------- | -------------------------------------------- |
| `observer.enabled`                     | `false` | Enable the background observer agent         |
| `observer.run_interval_minutes`        | `5`     | How often the observer analyzes observations |
| `observer.min_observations_to_analyze` | `20`    | Minimum observations before analysis runs    |

## File Structure

```text
$XDG_STATE_HOME/claude/homunculus/    # override with CLV2_HOMUNCULUS_DIR env var
+-- identity.json           # Your profile, technical level
+-- projects.json           # Registry: project hash -> name/path/remote
+-- observations.jsonl      # Global observations (fallback)
+-- instincts/
|   +-- personal/           # Global auto-learned instincts
|   +-- inherited/          # Global imported instincts
+-- evolved/
|   +-- agents/             # Global generated agents
|   +-- skills/             # Global generated skills
|   +-- commands/           # Global generated commands
+-- projects/
    +-- a1b2c3d4e5f6/       # Project hash (from git remote URL)
    |   +-- project.json    # Per-project metadata mirror (id/name/root/remote)
    |   +-- observations.jsonl
    |   +-- observations.archive/
    |   +-- instincts/
    |   |   +-- personal/   # Project-specific auto-learned
    |   |   +-- inherited/  # Project-specific imported
    |   +-- evolved/
    |       +-- skills/
    |       +-- commands/
    |       +-- agents/
    +-- f6e5d4c3b2a1/       # Another project
        +-- ...
```

## Scope Decision Guide

| Pattern Type                   | Scope       | Examples                                         |
| ------------------------------ | ----------- | ------------------------------------------------ |
| Language/framework conventions | **project** | "Use React hooks", "Follow Django REST patterns" |
| File structure preferences     | **project** | "Tests in `__tests__`/", "Components in src/"    |
| Code style                     | **project** | "Use functional style", "Prefer dataclasses"     |
| Error handling strategies      | **project** | "Use Result type for errors"                     |
| Security practices             | **global**  | "Validate user input", "Sanitize SQL"            |
| General best practices         | **global**  | "Write tests first", "Always handle errors"      |
| Tool workflow preferences      | **global**  | "Grep before Edit", "Read before Write"          |
| Git practices                  | **global**  | "Conventional commits", "Small focused commits"  |

## Instinct Promotion (Project -> Global)

When the same instinct appears in multiple projects with high confidence, it's a candidate for promotion to global scope.

**Auto-promotion criteria:**

- Same instinct ID in 2+ projects
- Average confidence >= 0.8

```bash
# Promote a specific instinct
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py promote prefer-explicit-errors

# Auto-promote all qualifying instincts
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py promote

# Preview without changes
python3 ${CLAUDE_CONFIG_DIR}/skills/continuous-learning-v2/scripts/instinct-cli.py promote --dry-run
```

The `/evolve` skill also suggests promotion candidates.

## Confidence Scoring

| Score | Meaning      | Behavior                      |
| ----- | ------------ | ----------------------------- |
| 0.3   | Tentative    | Suggested but not enforced    |
| 0.5   | Moderate     | Applied when relevant         |
| 0.7   | Strong       | Auto-approved for application |
| 0.9   | Near-certain | Core behavior                 |

**Confidence increases** when:

- Pattern is repeatedly observed
- User doesn't correct the suggested behavior
- Similar instincts from other sources agree

**Confidence decreases** when:

- User explicitly corrects the behavior
- Pattern isn't observed for extended periods
- Contradicting evidence appears

## Why Hooks vs Skills for Observation?

Hooks fire **100% of the time**, deterministically. Skills are probabilistic (~50-80%). This means:

- Every tool call is observed
- No patterns are missed
- Learning is comprehensive

## Privacy

- Observations stay **local** on your machine
- Project-scoped instincts are isolated per project
- Only **instincts** (patterns) can be exported -- not raw observations
- No actual code or conversation content is shared
- You control what gets exported and promoted

## Related

- [Skill Creator](https://skill-creator.app) - Generate instincts from repo history
- Homunculus - Community project that inspired the v2 instinct-based architecture
- [The Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352) - Continuous learning section

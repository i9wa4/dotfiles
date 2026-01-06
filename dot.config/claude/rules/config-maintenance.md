# Config Optimization Rules

These rules apply when editing CLAUDE.md / AGENTS.md or rules/ config files.

## 1. Purpose

Minimize startup context for efficient session initialization.

## 2. CLAUDE.md / AGENTS.md Design Guidelines

- YOU MUST: Focus only on persona and core guidelines
- YOU MUST: Split detailed rules into `rules/`
- NEVER: Include unnecessary information at startup (reference links, usage details)

## 3. Configuration Usage

| Type | Load Timing | Purpose |
| ---- | ----------- | ------- |
| CLAUDE.md / rules/ | Full load at startup | Global rules always applied |
| commands/ | Explicit user invocation | Predefined prompts, workflows |
| skills/ | Auto-triggered by conversation | Specialized knowledge, integrations |
| agents/ | Delegated via Task tool | Independent context for specialized tasks |

## 4. Optimization Checklist

Check the following when editing CLAUDE.md:

- [ ] Is the persona definition concise?
- [ ] Are basic rules truly needed at all times?
- [ ] Can detailed explanations be moved to rules/ or skills/?
- [ ] Have reference links been moved to config-maintenance.md?

## 5. Reference Links

- Claude Code config guide: <https://blog.atusy.net/2025/12/15/claude-code-user-config/>
- CLAUDE.md minimization: <https://blog.atusy.net/2025/12/17/minimizing-claude-md/>
- site2skill (Skills creation tool): <https://github.com/laiso/site2skill>

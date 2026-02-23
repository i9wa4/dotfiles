# Troubleshooting Guide

## Skill Won't Upload

### Error: "Could not find SKILL.md in uploaded folder"

- Rename to exactly `SKILL.md` (case-sensitive, no variations)
- Verify with `ls -la` showing `SKILL.md`

### Error: "Invalid frontmatter"

Common causes:

```yaml
# Wrong - missing --- delimiters
name: my-skill
description: Does things

# Wrong - unclosed quotes
description: "Does things

# Correct
---
name: my-skill
description: Does things
---
```

### Error: "Invalid skill name"

- Name must be kebab-case: `my-skill` not `My Skill` or `my_skill`
- No "claude" or "anthropic" prefix (reserved)

## Skill Does Not Trigger

Symptom: Skill never loads automatically.

Fix: Revise the `description` field.

Checklist:

- Too generic? ("Helps with projects" won't trigger)
- Missing trigger phrases users would actually say?
- Missing relevant file type mentions?

Debugging: Ask Claude "When would you use the [skill name] skill?"
Claude will quote the description back. Adjust based on what's missing.

## Skill Triggers Too Often

Symptom: Skill loads for unrelated queries.

Solutions:

1. Add negative triggers:

   ```text
   Do NOT use for simple data exploration (use data-viz skill instead).
   ```

2. Be more specific about scope:

   ```text
   # Too broad
   description: Processes documents

   # More specific
   description: Processes PDF legal documents for contract review
   ```

3. Clarify scope boundaries explicitly in description.

## Instructions Not Followed

Symptom: Skill loads but Claude ignores instructions.

Common causes and fixes:

1. **Too verbose** - Keep instructions concise, use bullet points, move
   detail to `references/`
2. **Critical info buried** - Put critical instructions at top, use
   `## Important` or `## Critical` headers
3. **Ambiguous language**:

   ```text
   # Bad
   Make sure to validate things properly

   # Good
   CRITICAL: Before calling create_project, verify:
   - Project name is non-empty
   - At least one team member assigned
   - Start date is not in the past
   ```

4. **Model laziness** - Add explicit encouragement in instructions:

   ```text
   ## Performance Notes
   - Take your time to do this thoroughly
   - Quality is more important than speed
   - Do not skip validation steps
   ```

   NOTE: Adding this in user prompts is more effective than in SKILL.md.

5. **For critical validations** - Consider a bundled script that performs
   checks programmatically. Code is deterministic; language is not.

## MCP Connection Issues

Symptom: Skill loads but MCP calls fail.

Checklist:

1. Verify MCP server is connected (Settings > Extensions > Connected status)
2. Check authentication (API keys valid, OAuth tokens refreshed)
3. Test MCP independently: ask Claude to call MCP directly without the skill
4. Verify tool names match exactly (case-sensitive)

## Large Context Issues

Symptom: Slow responses or degraded quality.

Causes:

- SKILL.md too large
- Too many skills enabled simultaneously
- All content loaded instead of progressive disclosure

Solutions:

1. Move detailed docs to `references/` and link from SKILL.md
2. Keep SKILL.md under 500 lines / 5,000 words
3. Evaluate if more than 20-50 skills are enabled simultaneously

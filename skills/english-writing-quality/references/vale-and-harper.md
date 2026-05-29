# Vale And Harper

Use these tools when prose quality matters for English documentation. They
complement `rumdl`: `rumdl` checks Markdown structure, Vale checks technical
documentation style, and Harper checks surface English locally.

In these dotfiles, Vale and Harper are installed as Home Manager user packages
so they are available globally after `nix run '.#switch'` or the relevant
Home Manager/nix-darwin switch. Vale's global config is `~/.vale.ini`, managed
as an out-of-store symlink from `config/vale/.vale.ini`.

## Choose The Tool

Use Vale when the question is:

- Does this English documentation match technical-writing style?
- Are terms, product names, and repeated words consistent?
- Should this become a deterministic repo rule later?

Use Harper when the question is:

- Is this English sentence grammatical?
- Are spelling, punctuation, article, or repeated-word issues present?
- Would local editor feedback help before review?

Run both for important README, docs, skill, or user-facing prose changes. For
small code comments or generated snippets, use judgment and avoid noisy passes.

## Vale Procedure

Vale is configured minimally in the Home Manager-managed `~/.vale.ini` with
the built-in `Vale` style. Run it against the files you want to review:

```sh
vale README.md docs/**/*.md skills/**/*.md
```

For focused checks, pass the global config explicitly when needed:

```sh
vale --config ~/.vale.ini path/to/file.md
```

Use Vale findings for technical-doc cleanup:

- repeated words;
- future repo terminology rules;
- future house-style rules;
- future vocabulary accept/reject lists.

Do not add strict CI enforcement until the relevant document set has a tuned
style and a clean baseline. The next global config step is to add a
Home Manager-managed Vale style and vocabulary under `config/vale/`, then point
`~/.vale.ini` at that style path. Do not add a dotfiles repo-root `.vale.ini`
only to make Vale work globally.

For project-specific baselines, design the project-local Vale config
separately and keep it in that project.

Keep first custom rules narrow and source-backed. Good early candidates are
product-name casing, repeated low-value phrases, and procedural wording that
has clear replacements.

## Harper Procedure

The nixpkgs package is `pkgs.harper`. It exposes `harper-cli` and `harper-ls`,
not a `harper` binary.

Run CLI checks with:

```sh
harper-cli lint README.md docs/**/*.md
```

Use compact output for review notes:

```sh
harper-cli lint --format compact path/to/file.md
```

Use JSON output when a script or later wrapper needs structured findings:

```sh
harper-cli lint --format json path/to/file.md
```

For editor integration, use the language server:

```sh
harper-ls --stdio
```

Start Harper as editor feedback or manual review evidence. Keep it out of
blocking CI until technical vocabulary and false positives are understood.

## Interpreting Findings

For each finding, choose one of three outcomes:

- Fix the text when the finding improves clarity and preserves meaning.
- Add vocabulary or a suppression path when the text is correct but tool
  knowledge is missing.
- Ignore or lower the rule when the finding is a style preference that conflicts
  with technical accuracy.

Never rewrite commands, identifiers, product names, file paths, code snippets,
or API names just to satisfy a prose checker. Prefer a short note in the task
artifact when a tool finding is intentionally ignored.

## Mixed Japanese And English Docs

Do not run English grammar advice over Japanese prose and expect useful output.
For mixed documents:

- check only English-heavy sections when possible;
- avoid rewriting Japanese labels or headings to satisfy English tools;
- treat romanized names, Japanese product terms, and local project names as
  vocabulary candidates;
- be careful with bullets that intentionally mix Japanese labels with English
  command fragments.

Harper has mixed-language support options, but treat them as something to test
on a small sample before using them broadly.

## AI Detector And Humanizer Non-Goals

Do not use AI detectors or humanizers for this workflow. They do not verify
technical accuracy, terminology, grammar, or house style. They also create bad
incentives: the goal is clear, correct documentation, not text that appears
human to a detector.

If prose feels generic, improve it by checking the facts, deleting filler,
using concrete nouns and verbs, and matching the repo's technical vocabulary.

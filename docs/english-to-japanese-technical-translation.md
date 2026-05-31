# English-to-Japanese Technical Translation Workflow

This docs page is the canonical source for the workflow text. The skill
reference at
`skills/english-to-japanese-technical-translation/references/workflow.md` is a
packaged copy for agent use and must be updated in the same change when this
page changes.

This workflow translates English technical articles into natural Japanese while
preserving technical accuracy, Markdown structure, code, commands, links,
terminology, and publication quality. It is a manual review workflow. It does
not define automation, chunking, provider selection, model selection, privacy
policy, or Markdown AST handling.

The workflow is also packaged as the
`english-to-japanese-technical-translation` agent skill so translation tasks
can load the same glossary-first process, prompt templates, and QA passes.
Automation remains a future follow-up after repeated use shows stable
boundaries that are worth implementing.

## 1. Prepare the Source

Start by making the source article explicit and stable.

Before pasting any source, draft, glossary, or style example into an AI tool or
translation service, confirm that:

- You have rights to translate the source, share it with the selected tool, and
  publish or distribute the translated derivative output on the target surface.
- Project policy allows the selected provider, model, network path, and data
  handling for this content.
- Confidential, credential, customer, or personal data has been removed, or the
  approved private workflow is being used.

If any of those checks is unclear, stop and get project approval before using
an external provider. This workflow does not choose the provider or define the
privacy policy.

1. Complete the privacy, source-rights, and provider-policy preflight.
2. Save or reference the exact source revision.
3. Identify the target publication surface and expected audience.
4. Decide the Japanese register before translation:
   - `desu/masu` for approachable tutorials, guides, and product articles.
   - `da/dearu` for formal essays, research notes, or documentation that
     already uses that register.
5. Preserve the source section structure unless the target publication has a
   clear reason to reorganize it.
6. List verbatim tokens and semantic or structural constraints before
   translation.
7. Build a glossary before translating body text.

Do not translate the full article in one pass. Translate section by section,
then run separate review passes over the combined result.

## 2. Protect Verbatim Tokens and Constraints

Verbatim tokens are copied exactly unless a reviewer deliberately changes them.
Semantic and structural constraints are not copied word for word; instead, their
meaning, severity, condition, alignment, and Markdown role must stay intact.
Mark both categories before translation and recheck them during publication QA.

| Span or constraint | Rule                                                               |
| ------------------ | ------------------------------------------------------------------ |
| Code fences        | Keep code, indentation, language tags, comments, and output exact. |
| Inline code        | Keep commands, paths, identifiers, literals, and options exact.    |
| URLs               | Keep link destinations exact.                                      |
| API names          | Keep method, class, parameter, and field names exact.              |
| Product names      | Keep official spelling and casing.                                 |
| UI labels          | Keep labels exact unless the product has an official Japanese UI.  |
| Version numbers    | Keep exact versions, ranges, and comparison operators.             |
| Warning meaning    | Preserve condition, severity, negation, and required action.       |
| Table structure    | Preserve headers, row meanings, alignment intent, and code spans.  |

Comments inside code fences, inline code, or copied command output are verbatim
tokens and stay exact. Prose that merely discusses a code comment can be
translated when doing so does not change behavior, copied output, or a
documented API contract.

If a verbatim token appears inside a sentence, translate only the
surrounding prose. Never localize an identifier, command, path, or option to
make the sentence read more naturally.

## 3. Build the Glossary First

Create a glossary before translating sections. Review it before every major
translation pass and update it only when a new term appears or a decision
changes.

Recommended columns:

| Field              | Purpose                                                        |
| ------------------ | -------------------------------------------------------------- |
| Source term        | Exact English term from the article.                           |
| Japanese rendering | The chosen Japanese expression or "keep English".              |
| Term type          | Product, API, concept, UI label, command, file path, or role.  |
| Rule               | Translate, keep English, use katakana, or bilingual first use. |
| First-use form     | The form to use the first time the term appears.               |
| Notes              | Reason, official docs reference, or ambiguity to watch.        |

Use these term-handling rules:

- Translate general concepts when Japanese engineering readers expect a
  Japanese term.
- Keep English for official product names, API names, commands, code
  identifiers, package names, repository names, and ecosystem terms that are
  normally used in English.
- Use katakana only when it is the natural Japanese technical term and does not
  obscure the original concept.
- Use first-use bilingual form when the English term is important for search or
  cross-reference, for example "Japanese term (English term)".
- Keep one rendering per term unless the article has a justified distinction.
- Record near-synonyms that must not drift across sections.

## 4. Translate Section by Section

Translate one section at a time. Include enough surrounding context for
pronouns, causal links, and terminology, but do not ask for a one-shot
translation of the whole article.

For each section:

1. Read the section and note its purpose.
2. Apply the glossary, verbatim-token list, and constraint list.
3. Translate paragraphs in order.
4. Preserve headings, lists, tables, notices, code fences, and link labels
   unless the target publication requires a local style adjustment.
5. Mark uncertain technical claims instead of guessing.
6. Run a quick local check against the source before moving to the next
   section.

Pay special attention to:

- Conditions and exceptions.
- Negation and double negatives.
- Warnings and required actions.
- Causal claims.
- Quantity, ordering, and comparison.
- "May", "must", "should", "can", and "will".
- Terms that have both product and general-language meanings.
- Captions, summaries, and notices that compress important claims.

## 5. Review Passes

Run review passes separately. Combining them tends to hide errors because each
pass optimizes for a different property.

### 5.1. Technical Accuracy

Compare the Japanese draft with the English source.

Checklist:

- Conditions, negation, warnings, and causal claims match the source.
- Quantifiers, comparison operators, ordering, and version numbers match.
- No examples, commands, constraints, or assumptions were added.
- No source details were dropped because they felt repetitive.
- Ambiguous source text is preserved as ambiguity or flagged for author review.
- Prose about code comments is translated only when doing so does not change
  executable behavior, copied output, or API expectations; actual comments
  inside code fences, inline code, or copied output stay exact.

### 5.2. Terminology Consistency

Compare the full draft against the glossary.

Checklist:

- Every glossary term uses the chosen rendering.
- First-use bilingual forms appear only where intended.
- Product names, API names, commands, identifiers, and UI labels keep official
  spelling and casing.
- Similar terms are not collapsed when the source distinguishes them.
- The same Japanese term is not used for two conflicting source concepts.

### 5.3. Japanese Editorial Quality

Read the draft as a Japanese technical article.

Checklist:

- Sentences are natural Japanese, not English syntax with Japanese words.
- Paragraphs have clear subjects and do not rely on ambiguous omitted subjects.
- The chosen register is consistent.
- The lead paragraph gives Japanese readers enough context.
- Headings are concise and useful for scanning.
- Transitions explain why each section follows the previous one.
- The text does not explain well-known engineering terms excessively.
- The text does not under-explain source-specific assumptions.

### 5.4. Technical Integrity

Inspect the Markdown, verbatim tokens, and constraints mechanically.

Checklist:

- Code fences, language tags, indentation, and command output are intact.
- Inline code spans are intact.
- Paths, URLs, anchors, image references, and link destinations are intact.
- Markdown tables still render correctly.
- Warning blocks, notices, and admonitions keep their intended severity.
- Numbers, versions, dates, option names, flags, and environment variables are
  unchanged unless intentionally localized in prose.

### 5.5. Final Publication QA

Review the article as it will be published.

Checklist:

- Headings form a coherent outline.
- The lead paragraph states the article's value clearly.
- Captions and alt text are natural and accurate.
- Notices and warnings are visible and correctly worded.
- Summaries do not introduce new claims.
- Markdown tables fit the target publication surface.
- Links work and point to the intended destinations.
- Code blocks are easy to copy and not damaged by formatting.
- The title, description, and tags match the final Japanese content.
- The final draft uses one register consistently.

## 6. Prompt Templates

Use these templates as reusable starting points. Replace bracketed placeholders
with project-specific context. Do not ask the model to change verbatim tokens or
constraints.

### 6.1. Project Style Contract

```text
You are helping translate an English technical article into natural Japanese.

Audience:
[Describe the Japanese engineering audience.]

Register:
[Choose desu/masu or da/dearu and explain why.]

Goals:
- Preserve technical accuracy.
- Preserve Markdown structure.
- Preserve code fences, inline code, commands, paths, URLs, API names,
  identifiers, product names, UI labels, version numbers, and comment text
  inside code fences or copied output exactly.
- Preserve warning conditions, table structure, and other semantic or
  structural constraints.
- Use the glossary consistently.
- Prefer natural Japanese technical prose over literal English word order.

Non-goals:
- Do not add examples, constraints, commands, version numbers, or product
  behavior not present in the source.
- Do not reorganize sections unless explicitly requested.
- Do not translate verbatim tokens.
```

### 6.2. Terminology Extraction

```text
Extract terminology from the following English technical section before
translation.

Return a Markdown table with these columns:
- Source term
- Japanese rendering
- Term type
- Rule: translate, keep English, katakana, or bilingual first use
- First-use form
- Notes

Prefer official product and API spelling. Mark uncertain terms instead of
guessing.

Existing glossary:
[Paste current glossary or say "none".]

Source section:
[Paste section.]
```

### 6.3. Section Translation

```text
Translate this section into Japanese using the project style contract and
glossary.

Requirements:
- Translate only this section.
- Preserve Markdown structure.
- Preserve verbatim tokens exactly.
- Preserve warning conditions, table structure, and other semantic or
  structural constraints.
- Keep terminology consistent with the glossary.
- Mark uncertainty with a short translator note instead of inventing details.

Glossary:
[Paste relevant glossary entries.]

Verbatim tokens and constraints:
[List exact tokens separately from semantic or structural constraints, or say
"all code, inline code, URLs, APIs, commands, paths, identifiers, product names,
UI labels, versions, and comment text inside code fences or copied output are
verbatim; warning conditions and Markdown tables are constraints".]

Source section:
[Paste section.]
```

### 6.4. Accuracy Review

```text
Compare the Japanese translation against the English source.

Focus only on technical accuracy:
- conditions and exceptions;
- negation;
- warnings;
- causal claims;
- quantifiers and comparisons;
- commands, code, paths, URLs, identifiers, APIs, and version numbers;
- hallucinated or omitted technical details.

Return findings as:
- Severity: must fix, should fix, or note
- Source excerpt
- Japanese excerpt
- Problem
- Suggested correction

English source:
[Paste source.]

Japanese translation:
[Paste translation.]
```

### 6.5. Japanese Editorial Pass

```text
Review this Japanese technical article for natural editorial quality.

Keep the technical meaning unchanged. Do not modify code, commands, paths,
URLs, identifiers, product names, API names, UI labels, or version numbers.

Check:
- natural Japanese sentence flow;
- register consistency;
- heading clarity;
- paragraph transitions;
- reader-level fit for Japanese engineers;
- excessive literal translation from English.

Return concise suggestions with the reason for each change.

Draft:
[Paste Japanese draft.]
```

### 6.6. Terminology Drift Check

```text
Check this Japanese draft against the glossary for terminology drift.

Return:
- terms that violate the glossary;
- first-use bilingual forms that are missing or repeated unnecessarily;
- product names, APIs, commands, identifiers, paths, UI labels, or version
  numbers that changed unexpectedly;
- source terms that appear to have multiple Japanese renderings.

Glossary:
[Paste glossary.]

Draft:
[Paste Japanese draft.]
```

### 6.7. Final Publication QA

```text
Perform final publication QA for this Japanese Markdown article.

Check:
- heading outline;
- lead paragraph;
- captions and callouts;
- summaries;
- Markdown tables;
- links and anchors;
- code fences and inline code;
- warnings and version numbers;
- register consistency;
- any remaining translator notes or unresolved uncertainty.

Do not rewrite the article. Return a checklist with pass/fail and exact items
that require correction.

Article:
[Paste final draft.]
```

## 7. Risk Mitigation

| Risk                                    | Mitigation                                                          |
| --------------------------------------- | ------------------------------------------------------------------- |
| Mistranslated conditions or negation    | Run the technical accuracy pass against source text.                |
| Terminology drift across sections       | Maintain the glossary and run the drift check on the full draft.    |
| Grammatically valid but unnatural prose | Run a separate Japanese editorial pass.                             |
| Hallucinated commands or constraints    | Require source comparison and forbid added technical details.       |
| Over-localized product or code terms    | Treat product, API, command, path, and identifier text as verbatim. |
| Markdown or code damage                 | Run technical integrity and publication QA passes.                  |
| Register inconsistency                  | Choose register up front and check it in final QA.                  |
| Reader-level mismatch                   | Define audience before translation and review for that audience.    |

## 8. When to Consider Automation

Consider automation only after this workflow has been used enough to reveal
stable repeatable boundaries. Good future automation candidates include:

- Verbatim-token extraction and constraint comparison.
- Glossary table generation from source sections.
- Markdown structural diffing before and after translation.
- Terminology drift checks.
- Link and code-fence integrity checks.
- Skill prompt examples or trigger checks that prove the workflow is invoked
  for the intended translation tasks.

Do not automate provider selection, cost controls, privacy policy, source
rights decisions, or source chunking as part of this initial documentation task.

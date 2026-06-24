# Prose Review

Use this reference for technical prose that reads generic, translated,
over-polished, or AI-like. It adapts task-relevant lessons from:

- <https://github.com/hardikpandya/stop-slop>
- <https://github.com/iKora128/stop-ai-slop-jp>

Do not treat this as an AI detector or a humanizer. The goal is clearer
technical writing with a visible author stance and preserved technical meaning.

## 1. Review Order

Fix deeper writing problems before surface artifacts:

1. Stance: name the claim, decision, uncertainty, or author judgment.
2. Agency: name who acts or decides; avoid giving human verbs to data,
   processes, culture, markets, documents, or tools.
3. Specificity: replace broad claims with concrete facts, examples, constraints,
   numbers, or repository evidence.
4. Structure: remove formulaic setup-reversal patterns, negative listings,
   proposition-like headings, and meta announcements.
5. Rhythm: vary paragraph length, sentence length, density, and endings.
6. Language: remove filler, vague intensifiers, business jargon, decorative
   punctuation, and repeated pet phrases.

## 2. English Checks

- Cut throat-clearing such as "here's why", "it turns out", "make no mistake",
  and section self-commentary.
- Prefer active voice with a named actor.
- Replace vague claims such as "the implications are significant" with the
  specific implication.
- Avoid binary contrast formulas. State the point directly when the contrast
  adds no evidence.
- Remove decorative emphasis, pull-quote phrasing, stacked adverbs, and
  mechanical three-item lists.

## 3. Japanese Checks

- Avoid translated English structure. Use natural Japanese word order and keep
  subjects explicit only when they help.
- Do not hide behind general subjects such as "many people" or "modern
  society" when the text is about a concrete author experience or project fact.
- Avoid proposition-style H2 headings that make each section sound like a
  speech. Prefer topic names or reader questions.
- Keep technical terms exact, but replace unnecessary katakana or IT metaphors
  when ordinary Japanese is clearer.
- Remove hollow abstractions, overlarge claims, decorative full-width dashes,
  unnecessary quotation marks, long middle-dot lists, and emoji decoration.

## 4. Technical Safety

- Do not add examples, constraints, commands, product behavior, numbers, or
  certainty that the source does not support.
- Preserve ambiguity when the evidence is ambiguous.
- Preserve code, identifiers, commands, paths, URLs, versions, API names,
  product names, and official UI labels.
- Use a separate technical-accuracy pass after editorial cleanup.

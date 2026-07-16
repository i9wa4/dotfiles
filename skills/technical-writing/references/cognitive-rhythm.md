# Cognitive Rhythm

Use this reference for explanatory prose that is technically correct but flat,
especially article-like chapters, essays, guides, and long explanations that
should carry a reader forward. The core idea is language-agnostic: prose rhythm
comes from changing the reader's cognitive mode, not from merely alternating
short and long sentences. Japanese examples require Japanese style judgment,
but the review tests below also apply to English.

This adapts the `cognitive-rhythm-writing` gist by k16shikano:
<https://gist.github.com/k16shikano/eb2929f13ed19c97188393d297be8432>.

## 1. Scope

- Use for revising or drafting from known source material, notes, outlines, or
  evidence. Do not invent scenes, data, claims, quotes, numbers, or uncertainty
  only to create rhythm.
- Use when the reader should experience a train of thought, not just retrieve
  reference facts.
- Skip for terse API references, checklists, changelogs, release notes, and
  operational procedures where predictability matters more than narrative
  motion.

## 2. Principles

- Treat rhythm as cognitive-mode switching: observation, uncertainty,
  assertion, and re-observation should alternate.
- Keep at least one source-backed open tension active: an unanswered question,
  an unverified expectation, a tradeoff, or a promise that the text later
  resolves.
- Write in a voice that appears to think through the material. Do not merely
  summarize finished conclusions.
- Build all tension and rhythm from the subject matter: events, data, code,
  tradeoffs, reader expectations, and the author's actual judgment state.
- Do not announce the technique in the prose. If the text says what the section
  will do next but adds no subject-matter information, the device is leaking.
- Do not shorten necessary context just to create punch. Rhythm only works
  after the reader has enough scope, comparison axis, and evidence to follow.

## 3. Paragraph Rhythm

- Give paragraphs a beat: establish footing, let the explanation run, then stop
  on a concrete judgment or next pressure point.
- Avoid long runs of assertions. Add grounded uncertainty, a reader objection,
  a tradeoff, or a concrete check before returning to assertion.
- After two or three dense paragraphs, add a sparse paragraph only if it fixes a
  result, switches viewpoint distance, or names the next thing to judge.
- Alternate viewpoint distance: move between concrete evidence such as records,
  values, code, or quoted claims, and a more abstract interpretation of what
  that evidence means.
- Use lists as compression and pause, then land the list back in the concrete
  case. A list that never returns to the subject matter feels like storage, not
  explanation.

## 4. Openings And Section Boundaries

- Open by creating a real tension within the first few sentences: a reader's
  felt problem, a plausible but fragile hypothesis, a surprising fact, or a
  prior section's unresolved question.
- Plain previews are allowed only when they carry an author stance or a reader
  pressure. A neutral table-of-contents sentence usually weakens the opening.
- Introduce theory, concepts, and citations after the reader has a felt
  mismatch or unnamed problem. Let theory name the problem instead of arriving
  as a prefabricated answer.
- Prefer section openings that inherit pressure from the previous section:
  restate the unresolved question, name a likely objection, or admit a
  tempting-but-incomplete approach.
- Avoid ending sections with progress narration such as "next we will examine
  ...". Put the bridge at the next section's opening when the subject matter
  gives you one.

## 5. Topic Test

For every paragraph-opening sentence, standalone short sentence, and newly
edited punch line, ask what it updates:

- Subject state: a fact, event, data point, quoted claim, code behavior,
  tradeoff, reader expectation, or author judgment. Keep or refine it.
- Document state: what this chapter, section, explanation, or argument will do
  next. Delete it unless it performs a concrete exception below.

Allow document-facing sentences only when they perform one of these jobs:

- Reject a specific reader misreading or objection.
- State or recover a real question that the prose has created.
- Open or close a necessary example frame.
- Place a boundary-level request, caveat, or author limitation that affects how
  the reader should interpret the material.

If deleting a document-state sentence breaks logic, rewrite the missing bridge
as subject-state content. If the rewrite still only describes the document,
delete it and rebuild the bridge from evidence, tradeoff, objection, or
judgment.

## 6. Revision Checklist

1. Topic test: mark paragraph openings and standalone short sentences as
   subject-state or document-state.
2. Device leak test: remove explicit technique words or progress narration that
   describe the intended rhythm instead of performing it.
3. Tension ledger: list every question, expectation, tradeoff, or promise; note
   where each is resolved or intentionally left open.
4. Beat check: find three or more consecutive assertive sentences and insert a
   grounded uncertainty, objection, concrete check, or pause where the source
   supports one.
5. Boundary check: move reader requests, caveats, and author modesty to
   openings or endings unless they directly affect a local inference.

## 7. Symptom Map

- Every paragraph feels the same: add beat variation and viewpoint-distance
  changes.
- Correct but hard to keep reading: create or restore an open tension from the
  subject matter.
- Theory sections lose energy: move the concept after the reader has a concrete
  mismatch or objection.
- Relaxed sentences feel flabby: run the topic test; keep only sentences that
  update subject state or a permitted boundary job.
- The ending feels preachy: land the abstraction back in an earlier concrete
  case, then close only the tensions the piece has earned.
- The opening feels administrative: replace neutral agenda-setting with reader
  pressure, a stance-bearing preview, or a concrete mismatch.

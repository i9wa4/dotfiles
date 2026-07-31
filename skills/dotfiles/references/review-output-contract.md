# Structured Review Output Contract

Use this contract when a review surface should emit machine-readable output.

Do not force this format onto every review. The repo's default human review
style is still findings first in concise prose. Use this contract only when a
consumer benefits from structured parsing or when you are designing a new
review-oriented prompt.

## 1. JSON Shape

```json
{
  "perspective": "architecture",
  "verdict": "approve",
  "summary": "Terse ship or no-ship assessment.",
  "findings": [
    {
      "severity": "high",
      "title": "Short issue title",
      "body": "What can go wrong, why this path is vulnerable, and likely impact.",
      "file": "path/to/file.ext",
      "line_start": 12,
      "line_end": 18,
      "confidence": 0.86,
      "recommendation": "Concrete fix or mitigation."
    }
  ],
  "next_steps": [
    "Follow-up action one"
  ]
}
```

## 2. Required Rules

- `verdict` is `needs-attention` if there is any material risk worth blocking
  on.
- `verdict` is `approve` only when you cannot support a substantive finding
  from the inspected context.
- Report only material findings. Skip style feedback, naming nits, or vague
  speculation.
- Every finding must include file and line coordinates, honest confidence, and
  a concrete recommendation.
- A blind reviewer uses a projection-relative alias path and line coordinates;
  use `no file applicable` when no inspected file supports the finding. The
  Guardian control envelope binds aliases to real repository paths after review.
- Keep claims grounded in inspected files or tool output.
- Prefer one strong finding over several weak ones.

### 2.1. Normal and blind modes

Normal mode uses real repository paths and any inspected Issue/PR/commit
evidence. Blind mode uses exactly one identity-safe representation: a supplied
projection-relative alias path and line coordinates, or `no file applicable`.
Blind mode never emits or infers real paths, filenames, Issue/PR/commit IDs,
URLs, authors, branches, timestamps, or candidate identity.

## 3. Severity Guidance

- `critical`: security, data loss, or irreversible production harm
- `high`: likely user-visible breakage or strong correctness risk
- `medium`: real defect or regression with narrower blast radius
- `low`: meaningful but less urgent weakness

## 4. When To Avoid This Contract

- The downstream consumer expects normal prose review comments
- The job is advisory rather than review-specific
- The available context is too thin to support precise file and line findings

# DaycraftLogic API

This document describes the public, protocol-based APIs for DaycraftLogic and
the compatibility guarantees for downstream consumers (App, CLI, third parties).

## Protocols

### RealityChecking
`evaluate(tasks:capacity:) -> RealityCheckResult`

- `tasks`: TaskItem list to evaluate.
- `capacity`: DailyCapacity (minutes).
- Returns: total minutes, capacity, and overload status.

### StaleDetecting
`staleTasks(in:referenceDate:calendar:) -> [TaskItem]`

- `tasks`: TaskItem list to scan.
- `referenceDate`: time anchor for "stale" comparison.
- `calendar`: calendar used for day calculations.
- Returns: tasks that satisfy the stale rules.

### Prioritizing
`prioritize(tasks:timeWindow:focusProfile:) -> [TaskItem]`

- `tasks`: TaskItem list to sort.
- `timeWindow`: optional TimeWindow for scoring.
- `focusProfile`: optional UserFocusProfile for scoring.
- Returns: tasks ordered by priority and proximity.

### InsightSummarizing
`summarize(tasks:) -> InsightSummary`

- `tasks`: TaskItem list to summarize.
- Returns: counts, completion rate, and estimates.

## Default Implementations

- `RealityCheck`: RealityChecking
- `StaleDetector`: StaleDetecting
- `Prioritizer`: Prioritizing
- `InsightEngine`: InsightSummarizing

## Compatibility Policy

- Versioning follows SemVer.
- Patch releases: no breaking changes to public APIs.
- Minor releases (0.x): breaking changes may occur, but will be documented in
  CHANGELOG with migration notes.
- Major releases (1.x+): breaking changes only in major versions, with explicit
  migration guidance.

# Changelog

All notable changes to this package will be documented in this file.

## [0.1.0] - 2026-01-14
### Added
- DaycraftModels with TaskItem/Project/Tag/Attachment/Recurrence types.
- DaycraftNLP parser for time, date, duration, tags, projects, priority, recurrence, and reminders.
- DaycraftLogic protocol-based APIs and default implementations:
  RealityCheck, StaleDetector, Prioritizer, InsightEngine.
- CLI subcommands: parse/create/list/export with JSON (Markdown optional).
- CLI filter expressions: +today/+tomorrow/+week, !overdue/+overdue,
  #tag/-#tag, status tokens, priority tokens, and @<project-uuid>.
- Unit tests for models, NLP, logic, and CLI command wiring.
- API documentation (`API.md`) and README updates.

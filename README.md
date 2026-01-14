# DaycraftEngine

## Overview
DaycraftEngine is the open-source Swift package that powers Daycraft's anti-guilt productivity logic. It provides data models, NLP parsing, core logic, and a macOS CLI. Current version: v0.1.0.

## Features
- DaycraftModels (TaskItem, Project, Tag, Attachment, Recurrence)
- DaycraftNLP parsing for time/date/recurrence/priority/tags/projects/reminders/time ranges
- DaycraftLogic: RealityCheck / StaleDetector / Prioritizer / Insight (protocol-based APIs)
- CLI commands: parse/create/list/export with JSON output (Markdown optional)

## Installation
- Swift Package Manager: add the repository URL in Xcode.
- Build CLI locally: `swift build` or `swift run daycraft`.

## CLI Usage
- `daycraft parse "Read paper #research 45m tomorrow"` -> JSON
- `daycraft create --title "Read paper" --estimate-minutes 45 --tag research --due 2025-10-12`
- `daycraft list --status todo --filter "+today #work"`
- `daycraft export --format json`

Filter expressions (list/export):
- `+today`, `+tomorrow`, `+week`
- `!overdue` / `+overdue`
- `#tag` / `-#tag`
- `/done` `/todo` `/inprogress` `/icebox` `/drop`
- `p1` `p2` `high` `normal` `low` `critical`
- `@<project-uuid>`

## API Usage
```swift
import DaycraftModels
import DaycraftLogic
import DaycraftNLP

let parser = DaycraftNLPParser()
let parsed = parser.parse("Read paper #research 45m tomorrow")

let task = TaskItem(
  title: parsed.title,
  estimatedMinutes: parsed.estimatedMinutes,
  dueDate: parsed.dueDate,
  priority: parsed.priority ?? .normal,
  tags: parsed.tags
)

let checker: RealityChecking = RealityCheck()
let result = checker.evaluate(tasks: [task], capacity: DailyCapacity(minutes: 480))
print(result.isOverloaded)
```

## API Stability

Public logic APIs are protocol-based for compatibility. See `API.md` for
the full protocol surface and compatibility policy.

## Contributing
Issues and PRs are welcome. Please include tests for new logic.

## Changelog
See `CHANGELOG.md` for release notes.

## Roadmap
- Phase 1: DaycraftModels + DaycraftNLP + core logic + CLI (v0.1.0)
- Phase 2: iOS app basics (SwiftUI, SwiftData, iCloud)
- Phase 3: advanced views, insights, automation, collaboration

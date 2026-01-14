//
//  main.swift
//  DaycraftEngine
//
//  Created by qinfuyao on 1/14/26.
//

import Foundation
import ArgumentParser
import DaycraftLogic
import DaycraftModels
import DaycraftNLP

@main
struct Daycraft: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "The Anti-Guilt Productivity Tool",
        version: "0.1.0",
        subcommands: [ParseCommand.self, CreateCommand.self, ListCommand.self, ExportCommand.self],
        defaultSubcommand: ParseCommand.self
    )
}

enum OutputFormat: String, ExpressibleByArgument {
    case json
    case markdown
}

extension TaskStatus: ExpressibleByArgument {}
extension TaskPriority: ExpressibleByArgument {}
extension RecurrenceFrequency: ExpressibleByArgument {}
extension Date: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: argument) {
            self = date
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: argument) {
            self = date
            return
        }

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        if let date = dateFormatter.date(from: argument) {
            self = date
            return
        }

        return nil
    }
}
extension UUID: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(uuidString: argument)
    }
}

struct ParseCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "parse",
        abstract: "Parse natural language into a task preview."
    )

    @Argument(parsing: .captureForPassthrough)
    var input: [String] = []

    @Option
    var format: OutputFormat = .json

    func run() throws {
        let text = input.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        let parser = DaycraftNLPParser()
        let result = parser.parse(text)
        try OutputWriter.write(result, format: format)
    }
}

struct CreateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a task."
    )

    @Option
    var title: String

    @Option
    var status: TaskStatus = .todo

    @Option(name: .customLong("estimate-minutes"))
    var estimateMinutes: Int?

    @Option
    var due: Date?

    @Option
    var start: Date?

    @Option
    var scheduled: Date?

    @Option(name: .customLong("completed-at"))
    var completedAt: Date?

    @Option
    var priority: TaskPriority = .normal

    @Option(parsing: .upToNextOption)
    var tag: [String] = []

    @Option(name: .customLong("project-id"))
    var projectId: UUID?

    @Option(name: .customLong("parent-id"))
    var parentId: UUID?

    @Option
    var notes: String?

    @Option(parsing: .upToNextOption)
    var attachment: [AttachmentInput] = []

    @Option(name: .customLong("recurrence-frequency"))
    var recurrenceFrequency: RecurrenceFrequency?

    @Option(name: .customLong("recurrence-interval"))
    var recurrenceInterval: Int = 1

    @Option(name: .customLong("recurrence-days-of-week"))
    var recurrenceDaysOfWeek: [Int] = []

    @Option(name: .customLong("recurrence-end-date"))
    var recurrenceEndDate: Date?

    @Option
    var format: OutputFormat = .json

    func run() throws {
        let attachments = attachment.map { Attachment(type: $0.type, url: $0.url, title: $0.title) }

        let recurrenceRule: RecurrenceRule? = {
            guard let frequency = recurrenceFrequency else { return nil }
            let days = recurrenceDaysOfWeek.isEmpty ? nil : recurrenceDaysOfWeek
            return RecurrenceRule(frequency: frequency, interval: recurrenceInterval, daysOfWeek: days, endDate: recurrenceEndDate)
        }()

        let now = Date()
        let task = TaskItem(
            title: title,
            status: status,
            estimatedMinutes: estimateMinutes,
            dueDate: due,
            startDate: start,
            scheduledDate: scheduled,
            completedAt: completedAt,
            priority: priority,
            tags: tag,
            projectId: projectId,
            parentId: parentId,
            notes: notes,
            attachments: attachments,
            recurrenceRule: recurrenceRule,
            deferCount: 0,
            iceboxReason: nil,
            createdAt: now,
            updatedAt: now
        )

        let store = FileTaskStore.defaultStore()
        var tasks = try store.load()
        tasks.append(task)
        try store.save(tasks)

        try OutputWriter.write(["task": task], format: format)
    }
}

struct ListCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List tasks with optional filters."
    )

    @Option
    var status: TaskStatus?

    @Option(parsing: .upToNextOption)
    var tag: [String] = []

    @Option(name: .customLong("project-id"))
    var projectId: UUID?

    @Option
    var filter: String?

    @Option
    var format: OutputFormat = .json

    func run() throws {
        let store = FileTaskStore.defaultStore()
        let tasks = try store.load()
        let filtered = TaskFilter(status: status, tags: tag, projectId: projectId, expression: filter).apply(to: tasks)
        try OutputWriter.write(["items": filtered], format: format)
    }
}

struct ExportCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export tasks."
    )

    @Option
    var format: OutputFormat = .json

    @Option
    var filter: String?

    func run() throws {
        let store = FileTaskStore.defaultStore()
        let tasks = try store.load()
        let filtered = TaskFilter(expression: filter).apply(to: tasks)
        try OutputWriter.write(["items": filtered], format: format)
    }
}

struct AttachmentInput: ExpressibleByArgument {
    let type: AttachmentType
    let url: String
    let title: String?

    init?(argument: String) {
        let parts = argument.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        guard parts.count >= 2 else { return nil }
        guard let type = AttachmentType(rawValue: parts[0]) else { return nil }
        self.type = type
        self.url = parts[1]
        self.title = parts.count >= 3 ? parts[2] : nil
    }
}

struct OutputWriter {
    static func write<T: Encodable>(_ value: T, format: OutputFormat) throws {
        switch format {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(value)
            if let output = String(data: data, encoding: .utf8) {
                print(output)
            }
        case .markdown:
            let markdown = MarkdownRenderer.render(value)
            print(markdown)
        }
    }
}

struct MarkdownRenderer {
    static func render<T>(_ value: T) -> String {
        if let task = value as? ParsedTask {
            var lines: [String] = ["- Title: \(task.title)"]
            if let status = task.status { lines.append("- Status: \(status.rawValue)") }
            if let estimate = task.estimatedMinutes { lines.append("- Estimate: \(estimate)m") }
            if let due = task.dueDate { lines.append("- Due: \(due)") }
            if let scheduled = task.scheduledDate { lines.append("- Scheduled: \(scheduled)") }
            if let priority = task.priority { lines.append("- Priority: \(priority.rawValue)") }
            if !task.tags.isEmpty { lines.append("- Tags: \(task.tags.joined(separator: ", "))") }
            if let project = task.project { lines.append("- Project: \(project)") }
            if let recurrence = task.recurrenceRule { lines.append("- Recurrence: \(recurrence.frequency.rawValue) every \(recurrence.interval)") }
            if let reminder = task.reminder {
                if let minutes = reminder.minutesBefore { lines.append("- Reminder: \(minutes)m before") }
                if let at = reminder.at { lines.append("- Reminder At: \(at)") }
            }
            return lines.joined(separator: "\n")
        }
        if let payload = value as? [String: TaskItem], let task = payload["task"] {
            return renderTaskList([task])
        }
        if let payload = value as? [String: [TaskItem]], let items = payload["items"] {
            return renderTaskList(items)
        }
        return String(describing: value)
    }

    private static func renderTaskList(_ tasks: [TaskItem]) -> String {
        if tasks.isEmpty { return "- (empty)" }
        return tasks.map { task in
            var line = "- \(task.title) [\(task.status.rawValue)]"
            if let due = task.dueDate { line += " due: \(due)" }
            if let estimate = task.estimatedMinutes { line += " (\(estimate)m)" }
            return line
        }.joined(separator: "\n")
    }
}

struct FileTaskStore {
    let url: URL

    static func defaultStore() -> FileTaskStore {
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let url = directory.appendingPathComponent("daycraft-tasks.json")
        return FileTaskStore(url: url)
    }

    func load() throws -> [TaskItem] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([TaskItem].self, from: data)
    }

    func save(_ tasks: [TaskItem]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(tasks)
        try data.write(to: url, options: [.atomic])
    }
}

struct TaskFilter {
    var status: TaskStatus?
    var tags: [String]
    var projectId: UUID?
    var expression: String?

    init(status: TaskStatus? = nil, tags: [String] = [], projectId: UUID? = nil, expression: String? = nil) {
        self.status = status
        self.tags = tags
        self.projectId = projectId
        self.expression = expression
    }

    func apply(to tasks: [TaskItem]) -> [TaskItem] {
        var result = tasks
        if let status = status {
            result = result.filter { $0.status == status }
        }
        if !tags.isEmpty {
            result = result.filter { task in
                Set(tags).isSubset(of: Set(task.tags))
            }
        }
        if let projectId = projectId {
            result = result.filter { $0.projectId == projectId }
        }
        if let expression = expression {
            result = applyExpression(expression, to: result)
        }
        return result
    }

    private func applyExpression(_ expression: String, to tasks: [TaskItem]) -> [TaskItem] {
        let tokens = expression.split(separator: " ").map { String($0) }
        var result = tasks
        for rawToken in tokens {
            let token = rawToken.lowercased()
            if token == "+today" {
                result = filterToday(tasks: result)
            } else if token == "+tomorrow" {
                result = filterTomorrow(tasks: result)
            } else if token == "+week" {
                result = filterNextDays(tasks: result, days: 7)
            } else if token == "!overdue" || token == "+overdue" {
                result = filterOverdue(tasks: result)
            } else if token.hasPrefix("-#") {
                let tag = String(rawToken.dropFirst(2))
                result = result.filter { !containsTag($0.tags, tag: tag) }
            } else if token.hasPrefix("#") {
                let tag = String(rawToken.dropFirst(1))
                result = result.filter { containsTag($0.tags, tag: tag) }
            } else if token.hasPrefix("@") {
                let idString = String(rawToken.dropFirst(1))
                if let uuid = UUID(uuidString: idString) {
                    result = result.filter { $0.projectId == uuid }
                }
            } else if let status = statusFromToken(token) {
                result = result.filter { $0.status == status }
            } else if let priority = priorityFromToken(token) {
                result = result.filter { $0.priority == priority }
            }
        }
        return result
    }

    private func filterToday(tasks: [TaskItem]) -> [TaskItem] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return tasks }
        return tasks.filter { task in
            guard let due = task.dueDate else { return false }
            return due >= start && due < end
        }
    }

    private func filterTomorrow(tasks: [TaskItem]) -> [TaskItem] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: 1, to: todayStart) else { return tasks }
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return tasks }
        return tasks.filter { task in
            guard let due = task.dueDate else { return false }
            return due >= start && due < end
        }
    }

    private func filterNextDays(tasks: [TaskItem], days: Int) -> [TaskItem] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: days, to: start) else { return tasks }
        return tasks.filter { task in
            guard let due = task.dueDate else { return false }
            return due >= start && due < end
        }
    }

    private func filterOverdue(tasks: [TaskItem]) -> [TaskItem] {
        let now = Date()
        return tasks.filter { task in
            guard let due = task.dueDate else { return false }
            return due < now && task.status != .done
        }
    }

    private func containsTag(_ tags: [String], tag: String) -> Bool {
        let target = tag.lowercased()
        return tags.contains { $0.lowercased() == target }
    }

    private func statusFromToken(_ token: String) -> TaskStatus? {
        switch token {
        case "/todo": return .todo
        case "/inprogress", "/in-progress": return .inProgress
        case "/done": return .done
        case "/icebox": return .icebox
        case "/drop", "/dropped": return .dropped
        default: return nil
        }
    }

    private func priorityFromToken(_ token: String) -> TaskPriority? {
        switch token {
        case "p1", "critical": return .critical
        case "p2", "high": return .high
        case "normal": return .normal
        case "low": return .low
        default: return nil
        }
    }
}

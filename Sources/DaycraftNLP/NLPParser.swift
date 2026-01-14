import Foundation
import DaycraftModels

public struct ParsedReminder: Codable, Equatable {
    public var minutesBefore: Int?
    public var at: Date?

    public init(minutesBefore: Int? = nil, at: Date? = nil) {
        self.minutesBefore = minutesBefore
        self.at = at
    }
}

public struct ParsedTask: Codable, Equatable {
    public var title: String
    public var status: TaskStatus?
    public var estimatedMinutes: Int?
    public var dueDate: Date?
    public var startDate: Date?
    public var scheduledDate: Date?
    public var completedAt: Date?
    public var priority: TaskPriority?
    public var tags: [String]
    public var project: String?
    public var recurrenceRule: RecurrenceRule?
    public var reminder: ParsedReminder?

    public init(
        title: String,
        status: TaskStatus? = nil,
        estimatedMinutes: Int? = nil,
        dueDate: Date? = nil,
        startDate: Date? = nil,
        scheduledDate: Date? = nil,
        completedAt: Date? = nil,
        priority: TaskPriority? = nil,
        tags: [String] = [],
        project: String? = nil,
        recurrenceRule: RecurrenceRule? = nil,
        reminder: ParsedReminder? = nil
    ) {
        self.title = title
        self.status = status
        self.estimatedMinutes = estimatedMinutes
        self.dueDate = dueDate
        self.startDate = startDate
        self.scheduledDate = scheduledDate
        self.completedAt = completedAt
        self.priority = priority
        self.tags = tags
        self.project = project
        self.recurrenceRule = recurrenceRule
        self.reminder = reminder
    }
}

public struct DaycraftNLPParser {
    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func parse(_ input: String, referenceDate: Date = Date()) -> ParsedTask {
        let lowercased = input.lowercased()

        let status = parseStatus(in: lowercased)
        let priority = parsePriority(in: lowercased)
        let tags = parseTags(in: input)
        let project = parseProject(in: input)
        let recurrenceRule = parseRecurrence(in: lowercased)
        let reminder = parseReminder(in: lowercased, referenceDate: referenceDate)

        let parsedDate = parseDate(in: lowercased, referenceDate: referenceDate)
        let timeRange = parseTimeRange(in: lowercased)
        let timePoint = parseTimePoint(in: lowercased)

        var estimatedMinutes = parseDurationMinutes(in: lowercased)
        var dueDate: Date?
        var scheduledDate: Date?

        if let date = parsedDate {
            dueDate = date
        }

        if let range = timeRange {
            let baseDate = parsedDate ?? calendar.startOfDay(for: referenceDate)
            scheduledDate = combine(date: baseDate, time: range.start)
            if estimatedMinutes == nil {
                estimatedMinutes = range.durationMinutes
            }
        } else if let time = timePoint {
            let baseDate = parsedDate ?? calendar.startOfDay(for: referenceDate)
            dueDate = combine(date: baseDate, time: time)
        }

        let title = extractTitle(from: input)

        return ParsedTask(
            title: title,
            status: status,
            estimatedMinutes: estimatedMinutes,
            dueDate: dueDate,
            startDate: nil,
            scheduledDate: scheduledDate,
            completedAt: nil,
            priority: priority,
            tags: tags,
            project: project,
            recurrenceRule: recurrenceRule,
            reminder: reminder
        )
    }

    // MARK: - Parsing Helpers

    private func parseStatus(in text: String) -> TaskStatus? {
        if text.contains("/done") { return .done }
        if text.contains("/icebox") { return .icebox }
        if text.contains("/drop") { return .dropped }
        return nil
    }

    private func parsePriority(in text: String) -> TaskPriority? {
        if text.contains("!!!") { return .critical }
        if text.contains("!!") { return .critical }
        if text.contains("!") { return .high }

        if text.contains(" p1 ") || text.hasPrefix("p1 ") || text.hasSuffix(" p1") { return .critical }
        if text.contains(" p2 ") || text.hasPrefix("p2 ") || text.hasSuffix(" p2") { return .high }

        if text.contains(" high ") { return .high }
        if text.contains(" low ") { return .low }
        if text.contains(" normal ") { return .normal }
        if text.contains(" critical ") { return .critical }

        return nil
    }

    private func parseTags(in text: String) -> [String] {
        let pattern = "#([A-Za-z0-9_\\-/]+)"
        return matches(in: text, pattern: pattern).map { $0 }
    }

    private func parseProject(in text: String) -> String? {
        let pattern = "@([A-Za-z0-9_\\-/]+)"
        return matches(in: text, pattern: pattern).first
    }

    private func parseRecurrence(in text: String) -> RecurrenceRule? {
        if text.contains("daily") {
            return RecurrenceRule(frequency: .daily, interval: 1)
        }
        if text.contains("weekly") {
            return RecurrenceRule(frequency: .weekly, interval: 1)
        }
        if text.contains("monthly") {
            return RecurrenceRule(frequency: .monthly, interval: 1)
        }
        if text.contains("yearly") {
            return RecurrenceRule(frequency: .yearly, interval: 1)
        }

        if let match = firstMatch(in: text, pattern: "every\\s+(\\d+)\\s+(day|days|week|weeks|month|months|year|years)") {
            let number = Int(match[1]) ?? 1
            let unit = match[2]
            if unit.contains("day") {
                return RecurrenceRule(frequency: .daily, interval: number)
            }
            if unit.contains("week") {
                return RecurrenceRule(frequency: .weekly, interval: number)
            }
            if unit.contains("month") {
                return RecurrenceRule(frequency: .monthly, interval: number)
            }
            if unit.contains("year") {
                return RecurrenceRule(frequency: .yearly, interval: number)
            }
        }

        if let weekday = parseWeekday(in: text) {
            return RecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [weekday])
        }

        return nil
    }

    private func parseReminder(in text: String, referenceDate: Date) -> ParsedReminder? {
        if let match = firstMatch(in: text, pattern: "(remind|alert)\\s+(\\d+)\\s*(m|min|mins|minutes)\\s+before") {
            let minutes = Int(match[2]) ?? 0
            return ParsedReminder(minutesBefore: minutes)
        }

        if let match = firstMatch(in: text, pattern: "(remind|alert)\\s+at\\s+([0-9]{1,2}(:[0-9]{2})?\\s*(am|pm)?)") {
            if let time = parseTimeComponents(from: match[2]) {
                let baseDate = calendar.startOfDay(for: referenceDate)
                let date = combine(date: baseDate, time: time)
                return ParsedReminder(at: date)
            }
        }

        return nil
    }

    private func parseDurationMinutes(in text: String) -> Int? {
        if let match = firstMatch(in: text, pattern: "(\\d+)\\s*h\\s*(\\d+)\\s*m") {
            let hours = Int(match[1]) ?? 0
            let minutes = Int(match[2]) ?? 0
            return hours * 60 + minutes
        }

        if let match = firstMatch(in: text, pattern: "(\\d+(?:\\.\\d+)?)\\s*h") {
            let hours = Double(match[1]) ?? 0
            return Int((hours * 60).rounded())
        }

        if let match = firstMatch(in: text, pattern: "(\\d+)\\s*(m|min|mins|minutes)") {
            return Int(match[1])
        }

        return nil
    }

    private func parseDate(in text: String, referenceDate: Date) -> Date? {
        if text.contains("today") {
            return calendar.startOfDay(for: referenceDate)
        }
        if text.contains("tomorrow") {
            guard let next = calendar.date(byAdding: .day, value: 1, to: referenceDate) else { return nil }
            return calendar.startOfDay(for: next)
        }

        if let match = firstMatch(in: text, pattern: "next\\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|tues|wed|thu|thur|thurs|fri|sat|sun)") {
            if let weekday = weekdayIndex(from: match[1]) {
                return nextWeekday(from: referenceDate, weekday: weekday, strictNext: true)
            }
        }

        if let match = firstMatch(in: text, pattern: "(\\d{4})-(\\d{2})-(\\d{2})") {
            let year = Int(match[1]) ?? 0
            let month = Int(match[2]) ?? 0
            let day = Int(match[3]) ?? 0
            return dateFrom(year: year, month: month, day: day)
        }

        if let match = firstMatch(in: text, pattern: "(\\d{1,2})/(\\d{1,2})") {
            let month = Int(match[1]) ?? 0
            let day = Int(match[2]) ?? 0
            let year = calendar.component(.year, from: referenceDate)
            return dateFrom(year: year, month: month, day: day)
        }

        if let weekday = parseWeekday(in: text) {
            return nextWeekday(from: referenceDate, weekday: weekday, strictNext: false)
        }

        return nil
    }

    private struct TimeRange {
        let start: TimeOfDay
        let end: TimeOfDay
        let durationMinutes: Int
    }

    private struct TimeOfDay {
        let hour: Int
        let minute: Int
    }

    private func parseTimeRange(in text: String) -> TimeRange? {
        guard let match = firstMatch(
            in: text,
            pattern: "(\\d{1,2})(?::(\\d{2}))?\\s*(am|pm)?\\s*-\\s*(\\d{1,2})(?::(\\d{2}))?\\s*(am|pm)?"
        ) else {
            return nil
        }

        let startHourRaw = Int(match[1]) ?? 0
        let startMinute = Int(match[2]) ?? 0
        let startMeridiem = match[3]

        let endHourRaw = Int(match[4]) ?? 0
        let endMinute = Int(match[5]) ?? 0
        let endMeridiem = match[6]

        let resolvedStart = resolveTime(hour: startHourRaw, minute: startMinute, meridiem: startMeridiem, fallbackMeridiem: endMeridiem)
        let resolvedEnd = resolveTime(hour: endHourRaw, minute: endMinute, meridiem: endMeridiem, fallbackMeridiem: startMeridiem)

        let duration = max(0, (resolvedEnd.hour * 60 + resolvedEnd.minute) - (resolvedStart.hour * 60 + resolvedStart.minute))

        return TimeRange(start: resolvedStart, end: resolvedEnd, durationMinutes: duration)
    }

    private func parseTimePoint(in text: String) -> TimeOfDay? {
        if let match = firstMatch(in: text, pattern: "(\\d{1,2}):(\\d{2})") {
            let hourRaw = Int(match[1]) ?? 0
            let minute = Int(match[2]) ?? 0
            return resolveTime(hour: hourRaw, minute: minute, meridiem: nil, fallbackMeridiem: nil)
        }
        if let match = firstMatch(in: text, pattern: "(\\d{1,2})\\s*(am|pm)") {
            let hourRaw = Int(match[1]) ?? 0
            let meridiem = match[2]
            return resolveTime(hour: hourRaw, minute: 0, meridiem: meridiem, fallbackMeridiem: nil)
        }
        return nil
    }

    private func resolveTime(hour: Int, minute: Int, meridiem: String?, fallbackMeridiem: String?) -> TimeOfDay {
        let finalMeridiem = meridiem ?? fallbackMeridiem
        var resolvedHour = hour
        if let meridiem = finalMeridiem {
            if meridiem == "pm" && hour < 12 {
                resolvedHour = hour + 12
            } else if meridiem == "am" && hour == 12 {
                resolvedHour = 0
            }
        }
        return TimeOfDay(hour: resolvedHour, minute: minute)
    }

    private func parseTimeComponents(from text: String) -> TimeOfDay? {
        let lowercased = text.lowercased()
        if let match = firstMatch(in: lowercased, pattern: "(\\d{1,2}):(\\d{2})") {
            let hourRaw = Int(match[1]) ?? 0
            let minute = Int(match[2]) ?? 0
            return resolveTime(hour: hourRaw, minute: minute, meridiem: nil, fallbackMeridiem: nil)
        }
        if let match = firstMatch(in: lowercased, pattern: "(\\d{1,2})\\s*(am|pm)") {
            let hourRaw = Int(match[1]) ?? 0
            let meridiem = match[2]
            return resolveTime(hour: hourRaw, minute: 0, meridiem: meridiem, fallbackMeridiem: nil)
        }
        return nil
    }

    private func parseWeekday(in text: String) -> Int? {
        let pattern = "(monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|tues|wed|thu|thur|thurs|fri|sat|sun)"
        guard let match = firstMatch(in: text, pattern: pattern) else { return nil }
        return weekdayIndex(from: match[1])
    }

    private func weekdayIndex(from text: String) -> Int? {
        switch text {
        case "sunday", "sun": return 1
        case "monday", "mon": return 2
        case "tuesday", "tue", "tues": return 3
        case "wednesday", "wed": return 4
        case "thursday", "thu", "thur", "thurs": return 5
        case "friday", "fri": return 6
        case "saturday", "sat": return 7
        default: return nil
        }
    }

    private func nextWeekday(from date: Date, weekday: Int, strictNext: Bool) -> Date? {
        let targetWeekday = weekday
        let currentWeekday = calendar.component(.weekday, from: date)
        var daysToAdd = (targetWeekday - currentWeekday + 7) % 7
        if daysToAdd == 0 && strictNext {
            daysToAdd = 7
        }
        guard let next = calendar.date(byAdding: .day, value: daysToAdd, to: date) else { return nil }
        return calendar.startOfDay(for: next)
    }

    private func dateFrom(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        return calendar.date(from: components)
    }

    private func combine(date: Date, time: TimeOfDay) -> Date? {
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = time.hour
        components.minute = time.minute
        return calendar.date(from: components)
    }

    private func extractTitle(from text: String) -> String {
        var cleaned = text
        let patterns = [
            "#[A-Za-z0-9_\\-/]+",
            "@[A-Za-z0-9_\\-/]+",
            "/(done|icebox|drop)",
            "(remind|alert)\\s+\\d+\\s*(m|min|mins|minutes)\\s+before",
            "(remind|alert)\\s+at\\s+[0-9]{1,2}(:[0-9]{2})?\\s*(am|pm)?",
            "\\d{4}-\\d{2}-\\d{2}",
            "\\d{1,2}/\\d{1,2}",
            "today|tomorrow|next\\s+\\w+|monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|tues|wed|thu|thur|thurs|fri|sat|sun",
            "\\d+\\s*h\\s*\\d+\\s*m",
            "\\d+(?:\\.\\d+)?\\s*h",
            "\\d+\\s*(m|min|mins|minutes)",
            "\\d{1,2}(:\\d{2})?\\s*(am|pm)?\\s*-\\s*\\d{1,2}(:\\d{2})?\\s*(am|pm)?",
            "\\d{1,2}:\\d{2}",
            "\\d{1,2}\\s*(am|pm)",
            "every\\s+\\d+\\s+(day|days|week|weeks|month|months|year|years)",
            "every\\s+\\w+",
            "daily|weekly|monthly|yearly",
            "!!!|!!|!|\\bp1\\b|\\bp2\\b|\\bhigh\\b|\\blow\\b|\\bnormal\\b|\\bcritical\\b"
        ]

        for pattern in patterns {
            cleaned = replacingMatches(in: cleaned, pattern: pattern, with: " ")
        }

        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func matches(in text: String, pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let nsRange = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, options: [], range: nsRange).compactMap { match in
            guard match.numberOfRanges > 1, let range = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[range])
        }
    }

    private func firstMatch(in text: String, pattern: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let nsRange = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: nsRange) else { return nil }
        var results: [String] = []
        for index in 0..<match.numberOfRanges {
            if let range = Range(match.range(at: index), in: text) {
                results.append(String(text[range]))
            } else {
                results.append("")
            }
        }
        return results
    }

    private func replacingMatches(in text: String, pattern: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return text }
        let nsRange = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: nsRange, withTemplate: replacement)
    }
}

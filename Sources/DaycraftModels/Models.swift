import Foundation

public struct TaskItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var status: TaskStatus
    public var estimatedMinutes: Int?
    public var dueDate: Date?
    public var startDate: Date?
    public var scheduledDate: Date?
    public var completedAt: Date?
    public var priority: TaskPriority
    public var tags: [String]
    public var projectId: UUID?
    public var parentId: UUID?
    public var notes: String?
    public var attachments: [Attachment]
    public var recurrenceRule: RecurrenceRule?
    public var deferCount: Int
    public var iceboxReason: String?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        status: TaskStatus = .todo,
        estimatedMinutes: Int? = nil,
        dueDate: Date? = nil,
        startDate: Date? = nil,
        scheduledDate: Date? = nil,
        completedAt: Date? = nil,
        priority: TaskPriority = .normal,
        tags: [String] = [],
        projectId: UUID? = nil,
        parentId: UUID? = nil,
        notes: String? = nil,
        attachments: [Attachment] = [],
        recurrenceRule: RecurrenceRule? = nil,
        deferCount: Int = 0,
        iceboxReason: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.status = status
        self.estimatedMinutes = estimatedMinutes
        self.dueDate = dueDate
        self.startDate = startDate
        self.scheduledDate = scheduledDate
        self.completedAt = completedAt
        self.priority = priority
        self.tags = tags
        self.projectId = projectId
        self.parentId = parentId
        self.notes = notes
        self.attachments = attachments
        self.recurrenceRule = recurrenceRule
        self.deferCount = deferCount
        self.iceboxReason = iceboxReason
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum TaskStatus: String, Codable {
    case todo
    case inProgress
    case done
    case icebox
    case dropped
}

public enum TaskPriority: String, Codable {
    case low
    case normal
    case high
    case critical
}

public struct Project: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var color: String
    public var icon: String
    public var archived: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        color: String,
        icon: String,
        archived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.archived = archived
    }
}

public struct Tag: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var color: String

    public init(
        id: UUID = UUID(),
        name: String,
        color: String
    ) {
        self.id = id
        self.name = name
        self.color = color
    }
}

public struct Attachment: Identifiable, Codable, Equatable {
    public let id: UUID
    public var type: AttachmentType
    public var url: String
    public var title: String?

    public init(
        id: UUID = UUID(),
        type: AttachmentType,
        url: String,
        title: String? = nil
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.title = title
    }
}

public enum AttachmentType: String, Codable {
    case link
    case image
    case file
}

public struct RecurrenceRule: Codable, Equatable {
    public var frequency: RecurrenceFrequency
    public var interval: Int
    public var daysOfWeek: [Int]?
    public var endDate: Date?

    public init(
        frequency: RecurrenceFrequency,
        interval: Int = 1,
        daysOfWeek: [Int]? = nil,
        endDate: Date? = nil
    ) {
        self.frequency = frequency
        self.interval = interval
        self.daysOfWeek = daysOfWeek
        self.endDate = endDate
    }
}

public enum RecurrenceFrequency: String, Codable {
    case daily
    case weekly
    case monthly
    case yearly
}

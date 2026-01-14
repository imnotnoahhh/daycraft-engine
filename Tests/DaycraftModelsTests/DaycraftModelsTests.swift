import XCTest
import DaycraftModels

final class DaycraftModelsTests: XCTestCase {
    func testTaskItemCodableRoundTrip() throws {
        let item = TaskItem(
            title: "Read paper",
            status: .todo,
            estimatedMinutes: 45,
            dueDate: Date(timeIntervalSince1970: 1_700_000_000),
            startDate: nil,
            scheduledDate: nil,
            completedAt: nil,
            priority: .normal,
            tags: ["research"],
            projectId: UUID(),
            parentId: nil,
            notes: "Notes",
            attachments: [Attachment(type: .link, url: "https://example.com")],
            recurrenceRule: RecurrenceRule(frequency: .weekly, interval: 1, daysOfWeek: [2]),
            deferCount: 1,
            iceboxReason: nil,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_700_000_100)
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(item)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TaskItem.self, from: data)

        XCTAssertEqual(item, decoded)
    }

    func testTaskItemEquatableSameFields() throws {
        let now = Date()
        let id = UUID()
        let first = TaskItem(id: id, title: "Same", createdAt: now, updatedAt: now)
        let second = TaskItem(id: id, title: "Same", createdAt: now, updatedAt: now)
        XCTAssertEqual(first, second)
    }

    func testEnumRawValues() throws {
        XCTAssertEqual(TaskStatus.todo.rawValue, "todo")
        XCTAssertEqual(TaskStatus.inProgress.rawValue, "inProgress")
        XCTAssertEqual(TaskStatus.done.rawValue, "done")
        XCTAssertEqual(TaskStatus.icebox.rawValue, "icebox")
        XCTAssertEqual(TaskStatus.dropped.rawValue, "dropped")

        XCTAssertEqual(TaskPriority.low.rawValue, "low")
        XCTAssertEqual(TaskPriority.normal.rawValue, "normal")
        XCTAssertEqual(TaskPriority.high.rawValue, "high")
        XCTAssertEqual(TaskPriority.critical.rawValue, "critical")

        XCTAssertEqual(RecurrenceFrequency.daily.rawValue, "daily")
        XCTAssertEqual(RecurrenceFrequency.weekly.rawValue, "weekly")
        XCTAssertEqual(RecurrenceFrequency.monthly.rawValue, "monthly")
        XCTAssertEqual(RecurrenceFrequency.yearly.rawValue, "yearly")
    }
}

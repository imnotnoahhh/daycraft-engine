import XCTest
import DaycraftModels
@testable import DaycraftNLP

final class DaycraftNLPTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return cal
    }

    private var referenceDate: Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }

    func testParseBasicTask() throws {
        let parser = DaycraftNLPParser(calendar: calendar)
        let result = parser.parse("Read paper #research 45m tomorrow", referenceDate: referenceDate)

        XCTAssertEqual(result.title, "Read paper")
        XCTAssertEqual(result.tags, ["research"])
        XCTAssertEqual(result.estimatedMinutes, 45)

        let expectedDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: referenceDate) ?? referenceDate)
        XCTAssertEqual(result.dueDate, expectedDate)
    }

    func testParseTimeRangeAndProject() throws {
        let parser = DaycraftNLPParser(calendar: calendar)
        let result = parser.parse("Design review @work/okrs next monday 9-11", referenceDate: referenceDate)

        XCTAssertEqual(result.project, "work/okrs")
        XCTAssertEqual(result.estimatedMinutes, 120)

        var expectedComponents = DateComponents()
        expectedComponents.year = 2025
        expectedComponents.month = 1
        expectedComponents.day = 6
        expectedComponents.hour = 9
        expectedComponents.minute = 0
        let expectedDate = calendar.date(from: expectedComponents)
        XCTAssertEqual(result.scheduledDate, expectedDate)
    }

    func testParseRecurrenceAndReminder() throws {
        let parser = DaycraftNLPParser(calendar: calendar)
        let result = parser.parse("Pay rent monthly remind 10m before", referenceDate: referenceDate)

        XCTAssertEqual(result.recurrenceRule?.frequency, .monthly)
        XCTAssertEqual(result.recurrenceRule?.interval, 1)
        XCTAssertEqual(result.reminder?.minutesBefore, 10)
    }

    func testParsePriority() throws {
        let parser = DaycraftNLPParser(calendar: calendar)
        let result = parser.parse("Write spec !!!", referenceDate: referenceDate)

        XCTAssertEqual(result.priority, .critical)
    }
}

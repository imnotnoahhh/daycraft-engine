//
//  DaycraftLogicTests.swift
//  DaycraftEngine
//
//  Created by qinfuyao on 1/14/26.
//

import XCTest
import DaycraftModels
@testable import DaycraftLogic

final class DaycraftLogicTests: XCTestCase {
    func testRealityCheckDetectsOverload() throws {
        let tasks = [
            TaskItem(title: "A", estimatedMinutes: 300),
            TaskItem(title: "B", estimatedMinutes: 300)
        ]
        let result = RealityCheck().evaluate(tasks: tasks, capacity: DailyCapacity(minutes: 480))
        XCTAssertTrue(result.isOverloaded)
        XCTAssertEqual(result.excessMinutes, 120)
    }

    func testStaleDetectorFindsStaleTasks() throws {
        let calendar = Calendar.current
        let referenceDate = Date()
        let oldDate = calendar.date(byAdding: .day, value: -10, to: referenceDate) ?? referenceDate
        let staleTask = TaskItem(title: "Old", status: .todo, deferCount: 4, createdAt: oldDate, updatedAt: oldDate)
        let freshTask = TaskItem(title: "New", status: .todo, deferCount: 1)
        let result = StaleDetector().staleTasks(in: [staleTask, freshTask], referenceDate: referenceDate, calendar: calendar)
        XCTAssertEqual(result, [staleTask])
    }

    func testPrioritizerSortsByPriorityAndDueDate() throws {
        let now = Date()
        let high = TaskItem(title: "High", dueDate: now.addingTimeInterval(3600), priority: .high)
        let low = TaskItem(title: "Low", dueDate: now, priority: .low)
        let critical = TaskItem(title: "Critical", dueDate: now.addingTimeInterval(7200), priority: .critical)
        let result = Prioritizer().prioritize(tasks: [low, high, critical])
        XCTAssertEqual(result.first?.title, "Critical")
    }

    func testInsightSummaryCounts() throws {
        let tasks = [
            TaskItem(title: "Done", status: .done, estimatedMinutes: 30),
            TaskItem(title: "Todo", status: .todo, estimatedMinutes: 60),
            TaskItem(title: "Icebox", status: .icebox)
        ]
        let summary = InsightEngine().summarize(tasks: tasks)
        XCTAssertEqual(summary.totalCount, 3)
        XCTAssertEqual(summary.completedCount, 1)
        XCTAssertEqual(summary.iceboxCount, 1)
        XCTAssertEqual(summary.averageEstimatedMinutes ?? 0, 45, accuracy: 0.1)
    }
}

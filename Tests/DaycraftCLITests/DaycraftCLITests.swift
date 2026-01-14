//
//  DaycraftCLITests.swift
//  DaycraftEngine
//
//  Created by qinfuyao on 1/14/26.
//

import XCTest
import DaycraftModels
@testable import DaycraftCLI

final class DaycraftCLITests: XCTestCase {
    private var originalDirectory: String = ""

    override func setUp() {
        super.setUp()
        originalDirectory = FileManager.default.currentDirectoryPath
    }

    override func tearDown() {
        FileManager.default.changeCurrentDirectoryPath(originalDirectory)
        super.tearDown()
    }

    func testCLIConfigurationVersionIsSet() throws {
        XCTAssertFalse(Daycraft.configuration.version.isEmpty)
    }

    func testCreateAndListPersistTasks() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        FileManager.default.changeCurrentDirectoryPath(tempDir.path)

        let create = try CreateCommand.parse(["--title", "Test Task", "--estimate-minutes", "30"])
        try create.run()

        let store = FileTaskStore.defaultStore()
        let tasks = try store.load()

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Test Task")
    }

    func testFilterExpressionToday() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        let tasks = [
            TaskItem(title: "Today", dueDate: today),
            TaskItem(title: "Tomorrow", dueDate: tomorrow)
        ]

        let filtered = TaskFilter(expression: "+today").apply(to: tasks)
        XCTAssertEqual(filtered.map(\.title), ["Today"])
    }

    func testFilterExpressionTomorrow() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        let tasks = [
            TaskItem(title: "Today", dueDate: today),
            TaskItem(title: "Tomorrow", dueDate: tomorrow)
        ]

        let filtered = TaskFilter(expression: "+tomorrow").apply(to: tasks)
        XCTAssertEqual(filtered.map(\.title), ["Tomorrow"])
    }

    func testFilterExpressionWeek() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let withinWeek = calendar.date(byAdding: .day, value: 3, to: today) ?? today
        let beyondWeek = calendar.date(byAdding: .day, value: 10, to: today) ?? today

        let tasks = [
            TaskItem(title: "Soon", dueDate: withinWeek),
            TaskItem(title: "Later", dueDate: beyondWeek)
        ]

        let filtered = TaskFilter(expression: "+week").apply(to: tasks)
        XCTAssertEqual(filtered.map(\.title), ["Soon"])
    }

    func testFilterExpressionTagIncludeExclude() throws {
        let tasks = [
            TaskItem(title: "Work", tags: ["work"]),
            TaskItem(title: "Home", tags: ["home"])
        ]

        let include = TaskFilter(expression: "#work").apply(to: tasks)
        XCTAssertEqual(include.map(\.title), ["Work"])

        let exclude = TaskFilter(expression: "-#home").apply(to: tasks)
        XCTAssertEqual(exclude.map(\.title), ["Work"])
    }

    func testFilterExpressionStatusPriorityAndProject() throws {
        let projectId = UUID()
        let tasks = [
            TaskItem(title: "Done", status: .done),
            TaskItem(title: "Critical", priority: .critical),
            TaskItem(title: "Project", projectId: projectId)
        ]

        let statusFiltered = TaskFilter(expression: "/done").apply(to: tasks)
        XCTAssertEqual(statusFiltered.map(\.title), ["Done"])

        let priorityFiltered = TaskFilter(expression: "p1").apply(to: tasks)
        XCTAssertEqual(priorityFiltered.map(\.title), ["Critical"])

        let projectFiltered = TaskFilter(expression: "@\(projectId.uuidString)").apply(to: tasks)
        XCTAssertEqual(projectFiltered.map(\.title), ["Project"])
    }

    func testSubcommandNamesAreStable() throws {
        XCTAssertEqual(ParseCommand._commandName, "parse")
        XCTAssertEqual(CreateCommand._commandName, "create")
        XCTAssertEqual(ListCommand._commandName, "list")
        XCTAssertEqual(ExportCommand._commandName, "export")
    }

    func testRootDispatchesParseSubcommand() throws {
        let command = try Daycraft.parseAsRoot(["parse", "Read paper"])
        XCTAssertTrue(command is ParseCommand)
    }

    func testRootDispatchesCreateSubcommand() throws {
        let command = try Daycraft.parseAsRoot(["create", "--title", "Task"])
        XCTAssertTrue(command is CreateCommand)
    }

    func testRootDispatchesListSubcommand() throws {
        let command = try Daycraft.parseAsRoot(["list"])
        XCTAssertTrue(command is ListCommand)
    }

    func testRootDispatchesExportSubcommand() throws {
        let command = try Daycraft.parseAsRoot(["export"])
        XCTAssertTrue(command is ExportCommand)
    }
}

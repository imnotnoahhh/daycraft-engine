import Foundation
import DaycraftModels

public protocol RealityChecking {
    func evaluate(tasks: [TaskItem], capacity: DailyCapacity) -> RealityCheckResult
}

public protocol StaleDetecting {
    func staleTasks(in tasks: [TaskItem], referenceDate: Date, calendar: Calendar) -> [TaskItem]
}

public protocol Prioritizing {
    func prioritize(tasks: [TaskItem], timeWindow: TimeWindow?, focusProfile: UserFocusProfile?) -> [TaskItem]
}

public protocol InsightSummarizing {
    func summarize(tasks: [TaskItem]) -> InsightSummary
}

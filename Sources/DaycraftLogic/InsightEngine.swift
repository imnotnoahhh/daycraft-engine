import Foundation
import DaycraftModels

public struct InsightEngine: InsightSummarizing {
    public init() {}

    public func summarize(tasks: [TaskItem]) -> InsightSummary {
        let total = tasks.count
        let completed = tasks.filter { $0.status == .done }.count
        let icebox = tasks.filter { $0.status == .icebox }.count
        let completionRate = total == 0 ? 0 : Double(completed) / Double(total)
        let estimates = tasks.compactMap { $0.estimatedMinutes }
        let averageEstimate = estimates.isEmpty ? nil : Double(estimates.reduce(0, +)) / Double(estimates.count)

        return InsightSummary(
            totalCount: total,
            completedCount: completed,
            iceboxCount: icebox,
            completionRate: completionRate,
            averageEstimatedMinutes: averageEstimate
        )
    }
}

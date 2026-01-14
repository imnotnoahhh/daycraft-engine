import Foundation
import DaycraftModels

public struct RealityCheck: RealityChecking {
    public init() {}

    public func evaluate(tasks: [TaskItem], capacity: DailyCapacity = DailyCapacity()) -> RealityCheckResult {
        let total = tasks
            .filter { $0.status == .todo || $0.status == .inProgress }
            .compactMap { $0.estimatedMinutes }
            .reduce(0, +)
        return RealityCheckResult(totalEstimatedMinutes: total, capacityMinutes: capacity.minutes)
    }
}

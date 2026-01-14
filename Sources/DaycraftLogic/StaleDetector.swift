import Foundation
import DaycraftModels

public struct StaleDetector: StaleDetecting {
    public var staleDaysThreshold: Int
    public var deferCountThreshold: Int

    public init(staleDaysThreshold: Int = 7, deferCountThreshold: Int = 3) {
        self.staleDaysThreshold = staleDaysThreshold
        self.deferCountThreshold = deferCountThreshold
    }

    public func staleTasks(in tasks: [TaskItem], referenceDate: Date = Date(), calendar: Calendar = .current) -> [TaskItem] {
        return tasks.filter { task in
            guard task.status == .todo else { return false }
            guard task.deferCount > deferCountThreshold else { return false }
            let days = calendar.dateComponents([.day], from: task.createdAt, to: referenceDate).day ?? 0
            return days > staleDaysThreshold
        }
    }
}

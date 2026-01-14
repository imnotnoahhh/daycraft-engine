import Foundation
import DaycraftModels

public struct Prioritizer: Prioritizing {
    public init() {}

    public func prioritize(tasks: [TaskItem], timeWindow: TimeWindow? = nil, focusProfile: UserFocusProfile? = nil) -> [TaskItem] {
        return tasks.sorted { lhs, rhs in
            let lhsScore = score(task: lhs, timeWindow: timeWindow, focusProfile: focusProfile)
            let rhsScore = score(task: rhs, timeWindow: timeWindow, focusProfile: focusProfile)
            if lhsScore != rhsScore {
                return lhsScore > rhsScore
            }
            switch (lhs.dueDate, rhs.dueDate) {
            case let (l?, r?):
                return l < r
            case (nil, _?):
                return false
            case (_?, nil):
                return true
            default:
                return lhs.title < rhs.title
            }
        }
    }

    private func score(task: TaskItem, timeWindow: TimeWindow?, focusProfile: UserFocusProfile?) -> Int {
        var score = 0
        switch task.priority {
        case .critical: score += 40
        case .high: score += 30
        case .normal: score += 20
        case .low: score += 10
        }

        if let due = task.dueDate {
            let hoursUntilDue = Int(due.timeIntervalSinceNow / 3600)
            if hoursUntilDue < 24 { score += 15 }
            else if hoursUntilDue < 72 { score += 10 }
            else if hoursUntilDue < 168 { score += 5 }
        }

        if let focusProfile = focusProfile, focusProfile.prefersDeepWorkMorning, let estimate = task.estimatedMinutes, estimate >= 60 {
            score += 5
        }

        if let window = timeWindow, let scheduled = task.scheduledDate {
            if scheduled >= window.start && scheduled <= window.end {
                score += 3
            }
        }

        return score
    }
}

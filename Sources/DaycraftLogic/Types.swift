import Foundation

public struct DailyCapacity: Equatable {
    public var minutes: Int

    public init(minutes: Int = 480) {
        self.minutes = minutes
    }
}

public struct RealityCheckResult: Equatable {
    public var totalEstimatedMinutes: Int
    public var capacityMinutes: Int
    public var excessMinutes: Int

    public var isOverloaded: Bool {
        excessMinutes > 0
    }

    public init(totalEstimatedMinutes: Int, capacityMinutes: Int) {
        self.totalEstimatedMinutes = totalEstimatedMinutes
        self.capacityMinutes = capacityMinutes
        self.excessMinutes = max(0, totalEstimatedMinutes - capacityMinutes)
    }
}

public struct TimeWindow: Equatable {
    public var start: Date
    public var end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}

public struct UserFocusProfile: Equatable {
    public var prefersDeepWorkMorning: Bool

    public init(prefersDeepWorkMorning: Bool = false) {
        self.prefersDeepWorkMorning = prefersDeepWorkMorning
    }
}

public struct InsightSummary: Equatable, Codable {
    public var totalCount: Int
    public var completedCount: Int
    public var iceboxCount: Int
    public var completionRate: Double
    public var averageEstimatedMinutes: Double?

    public init(
        totalCount: Int,
        completedCount: Int,
        iceboxCount: Int,
        completionRate: Double,
        averageEstimatedMinutes: Double?
    ) {
        self.totalCount = totalCount
        self.completedCount = completedCount
        self.iceboxCount = iceboxCount
        self.completionRate = completionRate
        self.averageEstimatedMinutes = averageEstimatedMinutes
    }
}

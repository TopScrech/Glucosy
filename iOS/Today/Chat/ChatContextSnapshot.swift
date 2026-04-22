#if os(iOS)
import Foundation

struct ChatContextSnapshot {
    let createdAt: Date
    let glucoseUnit: GlucoseUnit
    let isAuthorized: Bool
    let latestGlucose: Glucose?
    let latestInsulin: Insulin?
    let latestCarbs: Carbs?
    let latestWeight: Weight?
    let latestBMI: BMI?
    let glucoseTodayCount: Int
    let carbsTodayTotal: Double?
    let insulinTodayTotal: Double?
    let recentGlucose: [Glucose]
    let recentInsulin: [Insulin]
    let recentCarbs: [Carbs]

    init(healthKit: HealthKit, glucoseUnit: GlucoseUnit) {
        let glucoseToday = healthKit.glucoseRecords.filter {
            Calendar.current.isDateInToday($0.date)
        }
        let carbsToday = healthKit.carbsRecords.filter {
            Calendar.current.isDateInToday($0.date)
        }
        let insulinToday = healthKit.insulinRecords.filter {
            Calendar.current.isDateInToday($0.date)
        }

        createdAt = .now
        self.glucoseUnit = glucoseUnit
        isAuthorized = healthKit.isAuthorized
        latestGlucose = healthKit.glucoseRecords.first
        latestInsulin = healthKit.insulinRecords.first
        latestCarbs = healthKit.carbsRecords.first
        latestWeight = healthKit.weightRecords.first
        latestBMI = healthKit.bmiRecords.first
        glucoseTodayCount = glucoseToday.count
        carbsTodayTotal = Self.sum(for: carbsToday.map(\.value))
        insulinTodayTotal = Self.sum(for: insulinToday.map(\.value))
        recentGlucose = Array(healthKit.glucoseRecords.prefix(3))
        recentInsulin = Array(healthKit.insulinRecords.prefix(3))
        recentCarbs = Array(healthKit.carbsRecords.prefix(3))
    }

    var promptContext: String {
        [
            "Current date: \(createdAt.formatted(date: .abbreviated, time: .shortened))",
            "Selected glucose unit: \(glucoseUnit.title)",
            "Health data access: \(isAuthorized ? "authorized" : "not authorized or unavailable")",
            "Latest metrics:",
            "- Glucose: \(glucoseSummary)",
            "- Insulin: \(insulinSummary)",
            "- Carbs: \(carbsSummary)",
            "- Weight: \(weightSummary)",
            "- BMI: \(bmiSummary)",
            "Today:",
            "- Glucose readings: \(glucoseTodayCount.formatted())",
            "- Total carbs: \(formattedAmount(carbsTodayTotal)) g",
            "- Total insulin: \(formattedAmount(insulinTodayTotal)) U",
            "Recent glucose readings:",
            recentSection(for: recentGlucose, emptyText: "- None"),
            "Recent insulin entries:",
            recentSection(for: recentInsulin, emptyText: "- None"),
            "Recent carb entries:",
            recentSection(for: recentCarbs, emptyText: "- None")
        ]
        .joined(separator: "\n")
    }

    private var glucoseSummary: String {
        guard let latestGlucose else {
            return "Unavailable"
        }

        return "\(latestGlucose.formattedValue(in: glucoseUnit)) \(glucoseUnit.title) at \(formattedDate(latestGlucose.date))"
    }

    private var insulinSummary: String {
        guard let latestInsulin else {
            return "Unavailable"
        }

        return "\(formattedAmount(latestInsulin.value)) U at \(formattedDate(latestInsulin.date))"
    }

    private var carbsSummary: String {
        guard let latestCarbs else {
            return "Unavailable"
        }

        return "\(formattedAmount(latestCarbs.value)) g at \(formattedDate(latestCarbs.date))"
    }

    private var weightSummary: String {
        guard let latestWeight else {
            return "Unavailable"
        }

        return "\(latestWeight.value.formatted(.number.precision(.fractionLength(0 ... 1)))) kg at \(formattedDate(latestWeight.date))"
    }

    private var bmiSummary: String {
        guard let latestBMI else {
            return "Unavailable"
        }

        return "\(latestBMI.value.formatted(.number.precision(.fractionLength(0 ... 1)))) at \(formattedDate(latestBMI.date))"
    }

    private func recentSection(for records: [Glucose], emptyText: String) -> String {
        guard !records.isEmpty else {
            return emptyText
        }

        return records.map {
            "- \($0.formattedValue(in: glucoseUnit)) \(glucoseUnit.title) at \(formattedDate($0.date))"
        }
        .joined(separator: "\n")
    }

    private func recentSection(for records: [Insulin], emptyText: String) -> String {
        guard !records.isEmpty else {
            return emptyText
        }

        return records.map {
            "- \(formattedAmount($0.value)) U at \(formattedDate($0.date))"
        }
        .joined(separator: "\n")
    }

    private func recentSection(for records: [Carbs], emptyText: String) -> String {
        guard !records.isEmpty else {
            return emptyText
        }

        return records.map {
            "- \(formattedAmount($0.value)) g at \(formattedDate($0.date))"
        }
        .joined(separator: "\n")
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    private func formattedAmount(_ value: Double?) -> String {
        guard let value else {
            return "Unavailable"
        }

        return value.formatted(.number.precision(.fractionLength(0 ... 1)))
    }

    private static func sum(for values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        return values.reduce(0, +)
    }
}
#endif

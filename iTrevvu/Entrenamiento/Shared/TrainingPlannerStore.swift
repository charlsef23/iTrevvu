import Foundation
import Combine

@MainActor
final class TrainingPlannerStore: ObservableObject {

    @Published private(set) var plansByDayKey: [String: TrainingPlan] = [:]

    private let storageKey = "itrevvu.training.plans.v1"

    private let cal: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 2 // lunes
        return c
    }()

    init() {
        load()
    }

    func plan(for date: Date) -> TrainingPlan? {
        plansByDayKey[dayKey(date)]
    }

    func upsert(_ plan: TrainingPlan) {
        plansByDayKey[dayKey(plan.date)] = plan
        save()
    }

    func remove(for date: Date) {
        plansByDayKey.removeValue(forKey: dayKey(date))
        save()
    }

    // MARK: - Helpers

    func dayKey(_ date: Date) -> String {
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(plansByDayKey)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // print("❌ TrainingPlannerStore save error:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            plansByDayKey = try JSONDecoder().decode([String: TrainingPlan].self, from: data)
        } catch {
            plansByDayKey = [:]
        }
    }
}

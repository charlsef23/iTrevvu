import Foundation
import Combine
import Supabase

@MainActor
final class TrainingPlannerStore: ObservableObject {

    @Published private(set) var plansByDayKey: [String: TrainingPlan] = [:]
    @Published private(set) var isLoading = false

    private let service: TrainingSupabaseService
    private var autorId: UUID?

    private let cal: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 2
        return c
    }()

    init(client: SupabaseClient) {
        self.service = TrainingSupabaseService(client: client)
    }

    func bootstrap() async {
        do {
            autorId = try service.currentUserId()
        } catch { }
    }

    func plan(for date: Date) -> TrainingPlan? {
        plansByDayKey[dayKey(date)]
    }

    func loadRange(around date: Date) async {
        guard let autorId else { return }
        isLoading = true
        defer { isLoading = false }

        let from = cal.date(byAdding: .day, value: -45, to: date) ?? date
        let to = cal.date(byAdding: .day, value: 45, to: date) ?? date

        do {
            let rows = try await service.fetchPlans(autorId: autorId, from: from, to: to)
            var dict: [String: TrainingPlan] = [:]
            for r in rows {
                dict[r.fecha] = r.toPlan()
            }
            plansByDayKey = dict
        } catch {
            // print("loadRange error:", error)
        }
    }

    func upsert(_ plan: TrainingPlan) async {
        guard let autorId else { return }

        let key = dayKey(plan.date)

        // ✅ DTO Encodable (en vez de [String: Any])
        let dto = TrainingSupabaseService.UpsertPlanDTO(
            autor_id: autorId.uuidString,
            fecha: key,
            tipo: plan.kind.rawValue,
            rutina_id: nil, // si luego enlazas a rutinas, aquí meterías la UUID string
            rutina_titulo: plan.kind == .rutina ? plan.routineTitle : nil,
            duracion_minutos: plan.durationMinutes,
            nota: plan.note
        )

        do {
            let saved = try await service.upsertPlan(dto)
            plansByDayKey[key] = saved.toPlan()
        } catch {
            // print("upsert plan error:", error)
        }
    }

    func remove(for date: Date) async {
        guard let autorId else { return }
        let key = dayKey(date)

        do {
            try await service.deletePlan(autorId: autorId, dateKey: key)
            plansByDayKey.removeValue(forKey: key)
        } catch {
            // print("delete plan error:", error)
        }
    }

    // MARK: - Helpers

    func dayKey(_ date: Date) -> String {
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}

private extension DBPlan {
    func toPlan() -> TrainingPlan {
        TrainingPlan(
            id: id,
            date: ISO8601DateFormatter().date(from: fecha + "T00:00:00Z") ?? Date(),
            kind: TrainingPlanKind(rawValue: tipo) ?? .gimnasio,
            routineTitle: rutina_titulo,
            durationMinutes: duracion_minutos,
            note: nota
        )
    }
}

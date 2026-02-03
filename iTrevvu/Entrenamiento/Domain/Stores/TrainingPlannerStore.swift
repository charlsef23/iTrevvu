import Foundation
import Combine
import Supabase

@MainActor
final class TrainingPlannerStore: ObservableObject {

    @Published private(set) var sessionsByDayKey: [String: [PlannedSession]] = [:]
    @Published private(set) var isLoading = false

    private let service: TrainingPlannerSupabaseService
    private var autorId: UUID?

    var autorIdValue: UUID? { autorId }

    private let cal: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 2
        return c
    }()

    init(client: SupabaseClient) {
        self.service = TrainingPlannerSupabaseService(client: client)
    }

    func bootstrap() async {
        _ = await ensureAutorId()
    }

    private func ensureAutorId() async -> UUID? {
        if let autorId { return autorId }
        do {
            let id = try service.currentUserId()
            self.autorId = id
            return id
        } catch {
            self.autorId = nil
            return nil
        }
    }

    func dayKey(_ date: Date) -> String {
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }

    func sessions(for date: Date) -> [PlannedSession] {
        sessionsByDayKey[dayKey(date)] ?? []
    }

    func firstSession(for date: Date) -> PlannedSession? {
        sessions(for: date).first
    }

    func hasSessions(on date: Date) -> Bool {
        !(sessionsByDayKey[dayKey(date)] ?? []).isEmpty
    }

    func loadRange(around date: Date) async {
        guard let autorId = await ensureAutorId() else { return }

        isLoading = true
        defer { isLoading = false }

        let from = cal.date(byAdding: .day, value: -45, to: date) ?? date
        let to = cal.date(byAdding: .day, value: 45, to: date) ?? date

        do {
            let rows = try await service.fetchPlannedSessions(autorId: autorId, from: from, to: to)

            var dict: [String: [PlannedSession]] = [:]
            for r in rows {
                dict[r.fechaKey, default: []].append(r.toPlannedSession())
            }
            for (k, list) in dict {
                dict[k] = list.sorted(by: { $0.sortKey < $1.sortKey })
            }
            sessionsByDayKey = dict
        } catch {
            // opcional
        }
    }

    func upsertSession(_ session: PlannedSession) async {
        guard let autorId = await ensureAutorId() else { return }

        let dto = TrainingPlannerSupabaseService.UpsertPlannedSessionDTO(
            id: session.id.uuidString, // si quieres "nil para insertar", dímelo y lo ajusto
            autor_id: autorId.uuidString,
            fecha: session.fechaKey,
            hora: session.hora,
            tipo: session.tipo.rawValue,
            nombre: session.nombre,
            icono: session.icono,
            color: session.color,
            duracion_minutos: session.duracionMinutos,
            objetivo: session.objetivo,
            notas: session.notas,
            meta: session.meta
        )

        do {
            let saved = try await service.upsertPlannedSession(dto)
            let mapped = saved.toPlannedSession()
            let key = saved.fechaKey

            var list = sessionsByDayKey[key] ?? []
            if let idx = list.firstIndex(where: { $0.id == mapped.id }) {
                list[idx] = mapped
            } else {
                list.append(mapped)
            }
            list.sort(by: { $0.sortKey < $1.sortKey })
            sessionsByDayKey[key] = list
        } catch {
            // opcional
        }
    }

    func deleteSession(sessionId: UUID) async {
        do {
            try await service.deletePlannedSession(id: sessionId)

            for (key, list) in sessionsByDayKey {
                sessionsByDayKey[key] = list.filter { $0.id != sessionId }
            }
            sessionsByDayKey = sessionsByDayKey.filter { !$0.value.isEmpty }
        } catch {
            // opcional
        }
    }

    func loadSessionExercises(sessionId: UUID) async -> [PlannedSessionExercise] {
        do {
            let rows = try await service.fetchPlannedSessionExercises(sessionId: sessionId)
            return rows.map { $0.toPlannedSessionExercise() }
        } catch {
            return []
        }
    }

    func replaceSessionExercises(sessionId: UUID, items: [PlannedSessionExercise]) async -> Bool {
        let dtos: [TrainingPlannerSupabaseService.CreatePlannedSessionExerciseDTO] =
        items.enumerated().map { idx, it in
            .init(
                sesion_id: sessionId.uuidString,
                orden: idx,
                ejercicio_id: it.ejercicioId?.uuidString,
                nombre_override: it.nombreOverride,
                objetivo: it.objetivo,
                notas: it.notas
            )
        }

        do {
            try await service.replacePlannedSessionExercises(sessionId: sessionId, items: dtos)
            return true
        } catch {
            return false
        }
    }

    func upsertRepeatPlan(
        template: TrainingRepeatTemplate,
        startDate: Date,
        endDate: Date?,
        byweekday: [Int],
        hora: String?
    ) async {
        guard (await ensureAutorId()) != nil else { return }
        await service.upsertRepeatPlan(
            template: template,
            startDate: startDate,
            endDate: endDate,
            byweekday: byweekday,
            hora: hora
        )
    }
}

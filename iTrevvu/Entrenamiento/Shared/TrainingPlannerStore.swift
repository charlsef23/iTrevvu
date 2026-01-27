import Foundation
import Combine
import Supabase

@MainActor
final class TrainingPlannerStore: ObservableObject {

    // ✅ muchas sesiones por día (plan_sesiones)
    @Published private(set) var sessionsByDayKey: [String: [PlannedSession]] = [:]
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
        } catch {
            // print("bootstrap error:", error)
        }
    }

    // MARK: - Date helpers

    func dayKey(_ date: Date) -> String {
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    // MARK: - Public API (sessions)

    func sessions(for date: Date) -> [PlannedSession] {
        sessionsByDayKey[dayKey(date)] ?? []
    }

    func hasSessions(on date: Date) -> Bool {
        !(sessionsByDayKey[dayKey(date)] ?? []).isEmpty
    }

    // MARK: - Public API (plan alias para tu UI)

    /// ✅ Para que tu EntrenamientoView pueda usar `planner.plan(for:)`
    /// Aquí "plan" = la primera sesión del día (si hay varias).
    func plan(for date: Date) -> PlannedSession? {
        sessions(for: date).first
    }

    /// ✅ Para calendarios / puntito "hay plan"
    func hasPlan(on date: Date) -> Bool {
        plan(for: date) != nil
    }

    // MARK: - Load

    /// Carga un rango alrededor de la fecha (para semana/mes)
    func loadRange(around date: Date) async {
        guard let autorId else { return }
        isLoading = true
        defer { isLoading = false }

        let from = cal.date(byAdding: .day, value: -45, to: date) ?? date
        let to = cal.date(byAdding: .day, value: 45, to: date) ?? date

        do {
            let rows = try await service.fetchPlannedSessions(autorId: autorId, from: from, to: to)

            var dict: [String: [PlannedSession]] = [:]
            for r in rows {
                let key = r.fechaKey // "YYYY-MM-DD"
                dict[key, default: []].append(r.toPlannedSession())
            }

            // ordena por hora (si existe)
            for (k, list) in dict {
                dict[k] = list.sorted(by: { $0.sortKey < $1.sortKey })
            }

            sessionsByDayKey = dict
        } catch {
            // print("loadRange sessions error:", error)
        }
    }

    // MARK: - Session CRUD

    /// Crear / editar una sesión (upsert)
    func upsertSession(_ session: PlannedSession) async {
        guard let autorId else { return }

        let dto = TrainingSupabaseService.UpsertPlannedSessionDTO(
            id: session.id?.uuidString, // si nil -> crea
            autor_id: autorId.uuidString,
            fecha: session.fechaKey,    // "YYYY-MM-DD"
            hora: session.hora,         // "HH:mm:ss" o nil
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
            let key = saved.fechaKey

            var dayList = sessionsByDayKey[key] ?? []
            let mapped = saved.toPlannedSession()

            if let idx = dayList.firstIndex(where: { $0.id == mapped.id }) {
                dayList[idx] = mapped
            } else {
                dayList.append(mapped)
            }
            dayList.sort(by: { $0.sortKey < $1.sortKey })

            sessionsByDayKey[key] = dayList
        } catch {
            // print("upsertSession error:", error)
        }
    }

    /// Eliminar sesión completa (y sus ejercicios por cascade en DB)
    func deleteSession(sessionId: UUID) async {
        do {
            try await service.deletePlannedSession(id: sessionId)

            for (key, list) in sessionsByDayKey {
                let newList = list.filter { $0.id != sessionId }
                sessionsByDayKey[key] = newList
            }

            sessionsByDayKey = sessionsByDayKey.filter { !$0.value.isEmpty }
        } catch {
            // print("deleteSession error:", error)
        }
    }

    // MARK: - Exercises per session

    func loadSessionExercises(sessionId: UUID) async -> [PlannedSessionExercise] {
        do {
            let rows = try await service.fetchPlannedSessionExercises(sessionId: sessionId)
            return rows.map { $0.toPlannedSessionExercise() }
        } catch {
            return []
        }
    }

    /// Reemplaza toda la lista de ejercicios de una sesión
    func replaceSessionExercises(sessionId: UUID, items: [PlannedSessionExercise]) async -> Bool {
        let dtos: [TrainingSupabaseService.CreatePlannedSessionExerciseDTO] = items.enumerated().map { idx, it in
            TrainingSupabaseService.CreatePlannedSessionExerciseDTO(
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
}

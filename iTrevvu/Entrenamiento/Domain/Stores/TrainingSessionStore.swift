import Foundation
import Combine
import Supabase

@MainActor
final class TrainingSessionStore: ObservableObject {

    @Published private(set) var sessionId: UUID? = nil
    @Published var title: String = "Sesión"
    @Published var startedAt: Date = .now
    @Published var items: [TrainingSessionItem] = []
    @Published var isRunning: Bool = false

    private let service: TrainingSessionSupabaseService
    private var autorId: UUID?

    // Map en memoria: itemLocalId -> itemDBId
    private var itemDbIdByLocal: [UUID: UUID] = [:]
    // Map en memoria: setLocalId -> setDBId
    private var setDbIdByLocal: [UUID: UUID] = [:]

    private let iso = ISO8601DateFormatter()

    init(client: SupabaseClient) {
        self.service = TrainingSessionSupabaseService(client: client)
    }

    func bootstrap() async {
        do { autorId = try service.currentUserId() }
        catch { autorId = nil }
    }

    // MARK: - Start / Stop

    func start(tipo: TrainingSessionType, planSesionId: UUID?, title: String?) async {
        if autorId == nil { await bootstrap() }
        guard let autorId else { return }

        let cleaned = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = cleaned.isEmpty ? "Sesión" : cleaned
        self.startedAt = .now
        self.items = []
        self.itemDbIdByLocal = [:]
        self.setDbIdByLocal = [:]
        self.isRunning = true

        let dateKey = Self.dateKey(Date())
        let dto = TrainingSessionSupabaseService.CreateSessionDTO(
            autor_id: autorId.uuidString,
            fecha: dateKey,
            tipo: tipo.rawValue,
            plan_sesion_id: planSesionId?.uuidString,
            titulo: self.title,
            notas: nil,
            duracion_minutos: nil,
            estado: "en_progreso",
            started_at: iso.string(from: self.startedAt)
        )

        do {
            let sid = try await service.createSession(dto: dto)
            self.sessionId = sid
        } catch {
            self.isRunning = false
            self.sessionId = nil
        }
    }

    func finish() async {
        guard let sessionId else { return }
        isRunning = false

        let ended = Date()
        let minutes = max(1, Int(ended.timeIntervalSince(startedAt) / 60.0))

        let dto = TrainingSessionSupabaseService.UpdateSessionDTO(
            titulo: title,
            notas: nil,
            duracion_minutos: minutes,
            estado: "finalizada",
            ended_at: iso.string(from: ended)
        )

        try? await service.updateSession(sessionId: sessionId, dto: dto)
    }

    // MARK: - Items / Sets

    func addExercise(_ exercise: Exercise) async {
        guard let sessionId else { return }

        let orden = items.count
        let itemLocalId = UUID()

        var item = TrainingSessionItem(
            id: itemLocalId,
            sessionId: sessionId,
            orden: orden,
            ejercicioId: exercise.id,
            nombreSnapshot: exercise.nombre,
            notas: nil,
            sets: []
        )

        // 1) crear item en DB
        do {
            let itemDto = TrainingSessionSupabaseService.CreateItemDTO(
                sesion_id: sessionId.uuidString,
                orden: orden,
                ejercicio_id: exercise.id.uuidString,
                nombre_snapshot: exercise.nombre,
                notas: nil
            )
            let itemDbId = try await service.createItem(dto: itemDto)
            itemDbIdByLocal[itemLocalId] = itemDbId
        } catch {
            return
        }

        // 2) crear un set por defecto
        let setLocalId = UUID()
        let setOrden = 0
        let set = TrainingSet(
            id: setLocalId,
            orden: setOrden,
            reps: nil,
            pesoKg: nil,
            tiempoSeg: nil,
            distanciaM: nil,
            completado: false
        )

        do {
            guard let itemDbId = itemDbIdByLocal[itemLocalId] else { return }

            // ✅ SIN rpe
            let setDto = TrainingSessionSupabaseService.CreateSetDTO(
                sesion_item_id: itemDbId.uuidString,
                orden: setOrden,
                reps: nil,
                peso_kg: nil,
                tiempo_seg: nil,
                distancia_m: nil,
                completado: false
            )

            let setDbId = try await service.createSet(dto: setDto)
            setDbIdByLocal[setLocalId] = setDbId
        } catch {
            // si falla el set, igual dejamos item
        }

        item.sets = [set]
        items.append(item)
    }

    func addSet(to itemLocalId: UUID) async {
        guard let itemIdx = items.firstIndex(where: { $0.id == itemLocalId }) else { return }
        guard let itemDbId = itemDbIdByLocal[itemLocalId] else { return }

        let setOrden = items[itemIdx].sets.count
        let setLocalId = UUID()

        let newSet = TrainingSet(
            id: setLocalId,
            orden: setOrden,
            reps: nil,
            pesoKg: nil,
            tiempoSeg: nil,
            distanciaM: nil,
            completado: false
        )

        items[itemIdx].sets.append(newSet)

        do {
            // ✅ SIN rpe
            let dto = TrainingSessionSupabaseService.CreateSetDTO(
                sesion_item_id: itemDbId.uuidString,
                orden: setOrden,
                reps: nil,
                peso_kg: nil,
                tiempo_seg: nil,
                distancia_m: nil,
                completado: false
            )

            let setDbId = try await service.createSet(dto: dto)
            setDbIdByLocal[setLocalId] = setDbId
        } catch {
            // si falla, dejamos en UI (o podrías revertir)
        }
    }

    func updateSet(
        setLocalId: UUID,
        reps: Int?,
        pesoKg: Double?,
        tiempoSeg: Int?,
        distanciaM: Double?,
        completado: Bool
    ) async {
        guard let setDbId = setDbIdByLocal[setLocalId] else { return }

        // ✅ SIN rpe
        let dto = TrainingSessionSupabaseService.UpdateSetDTO(
            reps: reps,
            peso_kg: pesoKg,
            tiempo_seg: tiempoSeg,
            distancia_m: distanciaM,
            completado: completado
        )

        try? await service.updateSet(setId: setDbId, dto: dto)
    }

    // MARK: - helpers

    private static func dateKey(_ date: Date) -> String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}

import Foundation

// MARK: - SessionMeta (jsonb)

struct SessionMeta: Codable, Hashable {
    var values: [String: String] = [:]
    init(values: [String: String] = [:]) { self.values = values }
}

// MARK: - Repeat template (plan_repeticiones.template jsonb)

struct TrainingRepeatTemplate: Codable, Hashable {
    let tipo: String
    let nombre: String
    let icono: String
    let color: String
    let duracion_minutos: Int
    let notas: String?
}

// MARK: - Planned (plan_sesiones)

struct PlannedSession: Identifiable, Codable, Hashable {

    let id: UUID
    let date: Date
    let hora: String?
    let tipo: TrainingSessionType
    var nombre: String

    var icono: String?
    var color: String?

    var duracionMinutos: Int?
    var objetivo: String?
    var notas: String?
    var meta: SessionMeta?

    var createdAt: Date?
    var updatedAt: Date?

    init(
        id: UUID = UUID(),
        date: Date,
        hora: String? = nil,
        tipo: TrainingSessionType,
        nombre: String,
        icono: String? = nil,
        color: String? = nil,
        duracionMinutos: Int? = nil,
        objetivo: String? = nil,
        notas: String? = nil,
        meta: SessionMeta? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.hora = hora
        self.tipo = tipo
        self.nombre = nombre
        self.icono = icono
        self.color = color
        self.duracionMinutos = duracionMinutos
        self.objetivo = objetivo
        self.notas = notas
        self.meta = meta
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var fechaKey: String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    var sortKey: String {
        let hh = (hora ?? "99:99:99")
        return "\(fechaKey)|\(hh)"
    }
}

struct PlannedSessionExercise: Identifiable, Codable, Hashable {
    let id: UUID
    let sesionId: UUID
    let orden: Int

    var ejercicioId: UUID?
    var nombreOverride: String?

    var objetivo: [String: String]?
    var notas: String?

    init(
        id: UUID = UUID(),
        sesionId: UUID,
        orden: Int,
        ejercicioId: UUID? = nil,
        nombreOverride: String? = nil,
        objetivo: [String: String]? = nil,
        notas: String? = nil
    ) {
        self.id = id
        self.sesionId = sesionId
        self.orden = orden
        self.ejercicioId = ejercicioId
        self.nombreOverride = nombreOverride
        self.objetivo = objetivo
        self.notas = notas
    }
}

// MARK: - DB Rows (plan_sesiones / plan_sesion_ejercicios)

struct DBPlannedSession: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID
    let fecha: String
    let hora: String?

    let tipo: String
    let nombre: String

    let icono: String?
    let color: String?

    let duracion_minutos: Int?
    let objetivo: String?
    let notas: String?

    let meta: SessionMeta?

    let created_at: Date?
    let updated_at: Date?

    var fechaKey: String { fecha }
}

struct DBPlannedSessionExercise: Codable, Identifiable {
    let id: UUID
    let sesion_id: UUID
    let orden: Int

    let ejercicio_id: UUID?
    let nombre_override: String?

    let objetivo: [String: String]?
    let notas: String?

    let created_at: Date?
}

// MARK: - Mapping (DB -> Domain)

extension DBPlannedSession {
    func toPlannedSession() -> PlannedSession {
        let iso = ISO8601DateFormatter()
        let date = iso.date(from: "\(fecha)T00:00:00Z") ?? Date()

        return PlannedSession(
            id: id,
            date: date,
            hora: hora,
            tipo: TrainingSessionType(rawValue: tipo) ?? .gimnasio,
            nombre: nombre,
            icono: icono,
            color: color,
            duracionMinutos: duracion_minutos,
            objetivo: objetivo,
            notas: notas,
            meta: meta,
            createdAt: created_at,
            updatedAt: updated_at
        )
    }
}

extension DBPlannedSessionExercise {
    func toPlannedSessionExercise() -> PlannedSessionExercise {
        PlannedSessionExercise(
            id: id,
            sesionId: sesion_id,
            orden: orden,
            ejercicioId: ejercicio_id,
            nombreOverride: nombre_override,
            objetivo: objetivo,
            notas: notas
        )
    }
}

// MARK: - Live session enums

enum TrainingSessionState: String, Codable {
    case en_progreso
    case finalizada
    case cancelada
}

enum TrainingSessionType: String, Codable, CaseIterable, Identifiable {
    case gimnasio
    case cardio
    case movilidad
    case rutina
    case hiit
    case calistenia
    case deporte
    case rehab
    case descanso

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gimnasio: return "Gimnasio"
        case .cardio: return "Cardio"
        case .movilidad: return "Movilidad"
        case .rutina: return "Rutina"
        case .hiit: return "HIIT"
        case .calistenia: return "Calistenia"
        case .deporte: return "Deporte"
        case .rehab: return "Rehab"
        case .descanso: return "Descanso"
        }
    }
}

// MARK: - Live session models (sin RPE)

struct TrainingSet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var orden: Int
    var reps: Int?
    var pesoKg: Double?
    var tiempoSeg: Int?
    var distanciaM: Double?
    var completado: Bool

    init(
        id: UUID = UUID(),
        orden: Int,
        reps: Int? = nil,
        pesoKg: Double? = nil,
        tiempoSeg: Int? = nil,
        distanciaM: Double? = nil,
        completado: Bool = false
    ) {
        self.id = id
        self.orden = orden
        self.reps = reps
        self.pesoKg = pesoKg
        self.tiempoSeg = tiempoSeg
        self.distanciaM = distanciaM
        self.completado = completado
    }
}

struct TrainingSessionItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()          // local id (UI)
    var sessionId: UUID            // DB session id
    var orden: Int

    var ejercicioId: UUID?
    var nombreSnapshot: String
    var notas: String?

    var sets: [TrainingSet]

    init(
        id: UUID = UUID(),
        sessionId: UUID,
        orden: Int,
        ejercicioId: UUID? = nil,
        nombreSnapshot: String,
        notas: String? = nil,
        sets: [TrainingSet] = []
    ) {
        self.id = id
        self.sessionId = sessionId
        self.orden = orden
        self.ejercicioId = ejercicioId
        self.nombreSnapshot = nombreSnapshot
        self.notas = notas
        self.sets = sets
    }
}

struct TrainingSession: Identifiable, Codable, Hashable {
    var id: UUID
    var autorId: UUID
    var fecha: Date
    var tipo: TrainingSessionType

    var planSesionId: UUID?
    var titulo: String?
    var notas: String?

    var duracionMinutos: Int?
    var estado: TrainingSessionState

    var startedAt: Date
    var endedAt: Date?

    var items: [TrainingSessionItem]

    init(
        id: UUID,
        autorId: UUID,
        fecha: Date,
        tipo: TrainingSessionType,
        planSesionId: UUID? = nil,
        titulo: String? = nil,
        notas: String? = nil,
        duracionMinutos: Int? = nil,
        estado: TrainingSessionState = .en_progreso,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        items: [TrainingSessionItem] = []
    ) {
        self.id = id
        self.autorId = autorId
        self.fecha = fecha
        self.tipo = tipo
        self.planSesionId = planSesionId
        self.titulo = titulo
        self.notas = notas
        self.duracionMinutos = duracionMinutos
        self.estado = estado
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.items = items
    }
}

// MARK: - DB Rows live (sesiones_entrenamiento, sesion_items, sesion_sets)

struct DBTrainingSession: Codable, Identifiable {
    let id: UUID
    let autor_id: UUID
    let fecha: String
    let tipo: String
    let plan_sesion_id: UUID?

    let titulo: String?
    let notas: String?
    let duracion_minutos: Int?

    let estado: String
    let started_at: Date?
    let ended_at: Date?

    let created_at: Date?
    let updated_at: Date?
}

struct DBTrainingSessionItem: Codable, Identifiable {
    let id: UUID
    let sesion_id: UUID
    let orden: Int

    let ejercicio_id: UUID?
    let nombre_snapshot: String
    let notas: String?

    let created_at: Date?
}

struct DBTrainingSet: Codable, Identifiable {
    let id: UUID
    let sesion_item_id: UUID
    let orden: Int

    let reps: Int?
    let peso_kg: Double?
    let tiempo_seg: Int?
    let distancia_m: Double?
    let completado: Bool

    let created_at: Date?
    let updated_at: Date?
}

extension DBTrainingSession {
    func toDomain() -> TrainingSession {
        let day = Self.parseDay(fecha)
        return TrainingSession(
            id: id,
            autorId: autor_id,
            fecha: day,
            tipo: TrainingSessionType(rawValue: tipo) ?? .gimnasio,
            planSesionId: plan_sesion_id,
            titulo: titulo,
            notas: notas,
            duracionMinutos: duracion_minutos,
            estado: TrainingSessionState(rawValue: estado) ?? .en_progreso,
            startedAt: started_at ?? Date(),
            endedAt: ended_at
        )
    }

    private static func parseDay(_ yyyyMMdd: String) -> Date {
        let parts = yyyyMMdd.split(separator: "-")
        guard parts.count == 3,
              let y = Int(parts[0]),
              let m = Int(parts[1]),
              let d = Int(parts[2]) else { return Date() }

        var comps = DateComponents()
        comps.calendar = Calendar(identifier: .gregorian)
        comps.timeZone = TimeZone(secondsFromGMT: 0)
        comps.year = y
        comps.month = m
        comps.day = d
        return comps.date ?? Date()
    }
}

extension DBTrainingSet {
    func toDomain() -> TrainingSet {
        TrainingSet(
            id: id,
            orden: orden,
            reps: reps,
            pesoKg: peso_kg,
            tiempoSeg: tiempo_seg,
            distanciaM: distancia_m,
            completado: completado
        )
    }
}

extension DBTrainingSessionItem {
    func toDomain(sets: [TrainingSet]) -> TrainingSessionItem {
        TrainingSessionItem(
            id: id,
            sessionId: sesion_id,
            orden: orden,
            ejercicioId: ejercicio_id,
            nombreSnapshot: nombre_snapshot,
            notas: notas,
            sets: sets
        )
    }
}

// MARK: - Exercises

enum ExerciseType: String, CaseIterable, Identifiable, Codable {
    case fuerza, calistenia, cardio, hiit, core, movilidad, rehab, deporte, rutinas
    var id: String { rawValue }

    var title: String {
        switch self {
        case .fuerza: return "Fuerza"
        case .calistenia: return "Calistenia"
        case .cardio: return "Cardio"
        case .hiit: return "HIIT"
        case .core: return "Core"
        case .movilidad: return "Movilidad"
        case .rehab: return "Rehab"
        case .deporte: return "Deporte"
        case .rutinas: return "Rutinas"
        }
    }

    var icon: String {
        switch self {
        case .fuerza: return "dumbbell.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .cardio: return "figure.run"
        case .hiit: return "bolt.fill"
        case .core: return "circle.grid.cross.fill"
        case .movilidad: return "figure.cooldown"
        case .rehab: return "cross.case.fill"
        case .deporte: return "sportscourt.fill"
        case .rutinas: return "list.bullet.rectangle.portrait"
        }
    }
}

enum ExerciseMeasurementType: String, Codable {
    case peso_reps, reps, tiempo, distancia, calorias

    var title: String {
        switch self {
        case .peso_reps: return "Peso + reps"
        case .reps: return "Reps"
        case .tiempo: return "Tiempo"
        case .distancia: return "Distancia"
        case .calorias: return "Calorías"
        }
    }
}

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let tipo: ExerciseType
    let nombre: String
    let aliases: [String]
    let descripcion: String?
    let musculo_principal: String?
    let musculos_secundarios: [String]
    let equipo: [String]
    let patron: String?
    let tipo_medicion: ExerciseMeasurementType
    let video_url: String?
    let es_publico: Bool
    let autor_id: UUID?
    let created_at: Date?
    let updated_at: Date?
}


enum RecentPlanNamesStore {
    private static let key = "itreVvu_recent_plan_names_v1"
    private static let maxItems = 25

    static func load() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    static func append(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var items = load()

        // Evita duplicados (case insensitive)
        items.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }

        // Inserta al principio
        items.insert(trimmed, at: 0)

        // Limita tamaño
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }

        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}


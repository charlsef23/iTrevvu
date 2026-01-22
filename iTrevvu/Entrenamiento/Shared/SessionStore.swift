import Foundation
import Combine

/// ✅ STUB temporal (Fase 1: Planificador)
/// Todavía NO estamos sincronizando sesiones/historial con Supabase.
/// Este store existe solo para que el proyecto compile y para futuras fases.
@MainActor
final class SessionStore: ObservableObject {

    /// Modelo mínimo para poder mostrar “historial” en UI si lo necesitas
    struct SessionSummary: Identifiable, Equatable {
        let id: UUID
        let date: Date
        let title: String
        let subtitle: String
        let icon: String
    }

    @Published private(set) var recent: [SessionSummary] = []

    init() {}

    func bootstrap() async {
        // Nada por ahora
    }

    func refreshRecent(limit: Int = 20) async {
        // ✅ Mock temporal (puedes quitarlo si no lo usas)
        recent = [
            .init(id: UUID(), date: Date().addingTimeInterval(-86400), title: "Entrenamiento de fuerza", subtitle: "Ayer · 42 min", icon: "dumbbell.fill"),
            .init(id: UUID(), date: Date().addingTimeInterval(-86400 * 3), title: "Cardio · Carrera", subtitle: "Hace 3 días · 28 min", icon: "figure.run")
        ]
        if recent.count > limit { recent = Array(recent.prefix(limit)) }
    }

    // En la fase de “sesiones”, aquí añadiremos:
    // - saveSession(...)
    // - fetchRecentSessions(...) desde Supabase
}

import Foundation
import Combine
import Supabase

@MainActor
final class ExerciseStore: ObservableObject {

    @Published private(set) var global: [Exercise] = []
    @Published private(set) var custom: [Exercise] = []
    @Published private(set) var favorites: Set<UUID> = []
    @Published private(set) var isLoading = false

    private let service: TrainingExercisesSupabaseService
    private var autorId: UUID?

    init(client: SupabaseClient) {
        self.service = TrainingExercisesSupabaseService(client: client)
    }

    var all: [Exercise] { global + custom }

    func bootstrap() async {
        do {
            autorId = try service.currentUserId()
            try await refreshAll()
        } catch { }
    }

    func refreshAll() async throws {
        guard let autorId else { return }
        isLoading = true
        defer { isLoading = false }

        async let g = service.fetchGlobalExercises()
        async let u = service.fetchUserExercises(autorId: autorId)
        async let f = service.fetchFavorites(autorId: autorId)

        let (globalRows, userRows, favRows) = try await (g, u, f)

        global = globalRows.map { $0.toExercise(isCustom: false) }.sorted { $0.name < $1.name }
        custom = userRows.map { $0.toExercise(isCustom: true) }.sorted { $0.name < $1.name }

        favorites = Set(favRows.compactMap { $0.ejercicio_id ?? $0.ejercicio_usuario_id })
    }

    func isFavorite(_ id: UUID) -> Bool { favorites.contains(id) }

    func toggleFavorite(exerciseId: UUID, isCustom: Bool) async {
        guard let autorId else { return }

        do {
            if favorites.contains(exerciseId) {
                try await service.removeFavorite(
                    autorId: autorId,
                    ejercicioId: isCustom ? nil : exerciseId,
                    ejercicioUsuarioId: isCustom ? exerciseId : nil
                )
                favorites.remove(exerciseId)
            } else {
                try await service.addFavorite(
                    autorId: autorId,
                    ejercicioId: isCustom ? nil : exerciseId,
                    ejercicioUsuarioId: isCustom ? exerciseId : nil
                )
                favorites.insert(exerciseId)
            }
        } catch { }
    }

    func addCustom(_ exercise: Exercise) async {
        guard let autorId else { return }

        let dto = TrainingExercisesSupabaseService.CreateUserExerciseDTO(
            autor_id: autorId.uuidString,
            nombre: exercise.name,
            categoria: exercise.category.rawValue,
            musculo_principal: exercise.primary.rawValue,
            musculos_secundarios: exercise.secondary.map { $0.rawValue },
            equipo: exercise.equipment.map { $0.rawValue },
            patron: exercise.pattern.rawValue,
            is_unilateral: exercise.isUnilateral,
            is_bodyweight: exercise.isBodyweight,
            rep_range_default: exercise.defaultRepRange,
            tips: exercise.tips
        )

        do {
            let created = try await service.createUserExercise(dto)
            let ex = created.toExercise(isCustom: true)
            custom.append(ex)
            custom.sort { $0.name < $1.name }
        } catch { }
    }

    func deleteCustom(_ id: UUID) async {
        do {
            try await service.deleteUserExercise(id: id)
            custom.removeAll { $0.id == id }
            favorites.remove(id)
        } catch { }
    }

    func search(
        text: String,
        category: ExerciseCategory? = nil,
        primary: MuscleGroup? = nil,
        equipment: Equipment? = nil,
        onlyFavorites: Bool = false
    ) -> [Exercise] {

        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return all.filter { ex in
            if onlyFavorites && !favorites.contains(ex.id) { return false }
            if let category, ex.category != category { return false }
            if let primary, ex.primary != primary { return false }
            if let equipment, !ex.equipment.contains(equipment) { return false }

            if q.isEmpty { return true }
            if ex.name.lowercased().contains(q) { return true }
            if ex.primary.title.lowercased().contains(q) { return true }
            if ex.secondary.contains(where: { $0.title.lowercased().contains(q) }) { return true }
            return false
        }
        .sorted { $0.name < $1.name }
    }
}

private extension DBExercise {
    func toExercise(isCustom: Bool) -> Exercise {
        Exercise(
            id: id,
            name: nombre,
            category: ExerciseCategory(rawValue: categoria) ?? .fuerza,
            primary: MuscleGroup(rawValue: musculo_principal) ?? .fullBody,
            secondary: musculos_secundarios.compactMap { MuscleGroup(rawValue: $0) },
            equipment: equipo.compactMap { Equipment(rawValue: $0) },
            pattern: MovementPattern(rawValue: patron) ?? .aislamiento,
            isUnilateral: is_unilateral,
            isBodyweight: is_bodyweight,
            defaultRepRange: rep_range_default,
            tips: tips,
            isCustom: isCustom
        )
    }
}

private extension DBUserExercise {
    func toExercise(isCustom: Bool) -> Exercise {
        Exercise(
            id: id,
            name: nombre,
            category: ExerciseCategory(rawValue: categoria) ?? .fuerza,
            primary: MuscleGroup(rawValue: musculo_principal) ?? .fullBody,
            secondary: musculos_secundarios.compactMap { MuscleGroup(rawValue: $0) },
            equipment: equipo.compactMap { Equipment(rawValue: $0) },
            pattern: MovementPattern(rawValue: patron) ?? .aislamiento,
            isUnilateral: is_unilateral,
            isBodyweight: is_bodyweight,
            defaultRepRange: rep_range_default,
            tips: tips,
            isCustom: isCustom
        )
    }
}

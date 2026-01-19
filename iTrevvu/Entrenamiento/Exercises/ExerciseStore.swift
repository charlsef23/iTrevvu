import Foundation
import Combine

@MainActor
final class ExerciseStore: ObservableObject {

    // Base (no se guarda, viene del bundle)
    private let base = ExerciseLibrary.base

    // Persistencia
    private let customKey = "itrevvu.exercises.custom.v1"
    private let favKey = "itrevvu.exercises.favs.v1"

    @Published private(set) var custom: [Exercise] = []
    @Published private(set) var favorites: Set<UUID> = []

    init() {
        load()
    }

    var all: [Exercise] {
        // base + custom (custom al final)
        base + custom
    }

    func isFavorite(_ id: UUID) -> Bool {
        favorites.contains(id)
    }

    func toggleFavorite(_ id: UUID) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        saveFavorites()
    }

    func addCustom(_ exercise: Exercise) {
        var ex = exercise
        ex.isCustom = true
        custom.append(ex)
        saveCustom()
    }

    func deleteCustom(_ id: UUID) {
        custom.removeAll { $0.id == id }
        favorites.remove(id)
        saveCustom()
        saveFavorites()
    }

    // MARK: - Query

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

    // MARK: - Persistence

    private func load() {
        // custom
        if let data = UserDefaults.standard.data(forKey: customKey),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            custom = decoded
        }

        // favs
        if let data = UserDefaults.standard.data(forKey: favKey),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            favorites = Set(decoded)
        }
    }

    private func saveCustom() {
        if let data = try? JSONEncoder().encode(custom) {
            UserDefaults.standard.set(data, forKey: customKey)
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(Array(favorites)) {
            UserDefaults.standard.set(data, forKey: favKey)
        }
    }
}

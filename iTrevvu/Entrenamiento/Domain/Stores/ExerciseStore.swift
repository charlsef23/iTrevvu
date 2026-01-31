import Foundation
import Combine
import Supabase

@MainActor
final class ExerciseStore: ObservableObject {

    @Published private(set) var byType: [ExerciseType: [Exercise]] = [:]
    @Published private(set) var favorites: Set<UUID> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    private let service: ExerciseSupabaseService
    private var autorId: UUID?

    init(client: SupabaseClient) {
        self.service = ExerciseSupabaseService(client: client)
    }

    func bootstrap() async {
        do { autorId = try service.currentUserId() }
        catch { autorId = nil }
    }

    func load(type: ExerciseType) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            if autorId == nil { await bootstrap() }
            let list = try await service.fetchExercises(type: type)
            byType[type] = list

            if let autorId {
                let favIds = try await service.fetchFavoriteIds(autorId: autorId)
                favorites = Set(favIds)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isFavorite(_ id: UUID) -> Bool {
        favorites.contains(id)
    }

    func toggleFavorite(exerciseId: UUID) async {
        guard let autorId else { return }
        do {
            if favorites.contains(exerciseId) {
                try await service.removeFavorite(autorId: autorId, exerciseId: exerciseId)
                favorites.remove(exerciseId)
            } else {
                try await service.addFavorite(autorId: autorId, exerciseId: exerciseId)
                favorites.insert(exerciseId)
            }
        } catch {
            // no bloqueamos UI
        }
    }
}

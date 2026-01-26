import Foundation
import Combine
import SwiftUI

@MainActor
final class ExerciseStore: ObservableObject {
    @Published var byType: [ExerciseType: [Exercise]] = [:]
    @Published var favorites: Set<UUID> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service = TrainingExercisesSupabaseService.shared

    private var currentUserId: UUID? {
        AuthService.shared.sessionUserId
    }

    func load(type: ExerciseType, search: String? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let items = try await service.fetchExercises(type: type, search: search)
            byType[type] = items

            if let uid = currentUserId {
                favorites = try await service.fetchFavorites(for: uid)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite(exerciseId: UUID) async {
        guard let uid = currentUserId else { return }

        do {
            if favorites.contains(exerciseId) {
                try await service.removeFavorite(autorId: uid, ejercicioId: exerciseId)
                favorites.remove(exerciseId)
            } else {
                try await service.addFavorite(autorId: uid, ejercicioId: exerciseId)
                favorites.insert(exerciseId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isFavorite(_ id: UUID) -> Bool { favorites.contains(id) }
}

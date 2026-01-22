import Foundation
import Combine
import Supabase

@MainActor
final class RoutineStore: ObservableObject {

    @Published private(set) var routines: [DBRoutine] = []
    @Published private(set) var isLoading = false

    private let service: TrainingSupabaseService
    private var autorId: UUID?

    init(client: SupabaseClient) {
        self.service = TrainingSupabaseService(client: client)
    }

    func bootstrap() async {
        do {
            autorId = try service.currentUserId()
            await refresh()
        } catch {
            // print("RoutineStore bootstrap error:", error)
        }
    }

    func refresh() async {
        guard let autorId else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            routines = try await service.fetchRoutines(autorId: autorId)
        } catch {
            // print("RoutineStore refresh error:", error)
        }
    }
}

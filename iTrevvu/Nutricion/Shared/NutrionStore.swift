import Foundation
import SwiftUI
import Combine

@MainActor
final class NutritionStore: ObservableObject {

    @Published private(set) var day: NutritionDay = .empty(date: Date())
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: NutritionServiceProtocol

    // ✅ OJO: quitamos el default NutritionService() aquí para evitar el error de actor
    init(service: NutritionServiceProtocol) {
        self.service = service
    }

    // ✅ Init cómodo que ya crea el service en contexto MainActor
    convenience init() {
        self.init(service: NutritionService())
    }

    func loadDay(_ date: Date = Date()) async {
        isLoading = true
        errorMessage = nil
        do {
            day = try await service.fetchDay(date: date)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addFood(_ food: Food, grams: Double, to meal: MealType) async {
        guard grams > 0 else { return }
        var updated = day

        guard let idx = updated.meals.firstIndex(where: { $0.type == meal }) else { return }
        let item = MealItem(id: UUID(), food: food, grams: grams)
        updated.meals[idx].items.insert(item, at: 0)

        await persist(updated)
    }

    func removeItem(mealType: MealType, itemId: UUID) async {
        var updated = day
        guard let idx = updated.meals.firstIndex(where: { $0.type == mealType }) else { return }
        updated.meals[idx].items.removeAll { $0.id == itemId }
        await persist(updated)
    }

    func addWater(ml: Int) async {
        guard ml > 0 else { return }
        var updated = day
        updated.water.ml = min(updated.water.ml + ml, updated.water.goalML)
        await persist(updated)
    }

    func setWaterGoal(_ goal: Int) async {
        var updated = day
        updated.water.goalML = max(500, goal)
        updated.water.ml = min(updated.water.ml, updated.water.goalML)
        await persist(updated)
    }

    private func persist(_ newDay: NutritionDay) async {
        day = newDay
        do {
            try await service.upsertDay(newDay)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

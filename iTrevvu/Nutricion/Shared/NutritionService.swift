import Foundation

protocol NutritionServiceProtocol {
    func fetchDay(date: Date) async throws -> NutritionDay
    func upsertDay(_ day: NutritionDay) async throws

    func searchFoods(query: String) async throws -> [Food]
    func toggleFavorite(foodId: UUID, isFavorite: Bool) async throws
}

struct NutritionService: NutritionServiceProtocol {

    func fetchDay(date: Date) async throws -> NutritionDay {
        // Mock inicial (luego Supabase)
        return .empty(date: date)
    }

    func upsertDay(_ day: NutritionDay) async throws {
        // Guardado (luego Supabase)
    }

    func searchFoods(query: String) async throws -> [Food] {
        // Mock: replace por tabla foods / API externa si quieres
        let all: [Food] = [
            .mock,
            Food(id: UUID(), name: "Arroz blanco", brand: nil, kcalPer100: 130, proteinPer100: 2.7, carbsPer100: 28, fatPer100: 0.3),
            Food(id: UUID(), name: "Pechuga de pollo", brand: nil, kcalPer100: 165, proteinPer100: 31, carbsPer100: 0, fatPer100: 3.6),
            Food(id: UUID(), name: "Plátano", brand: nil, kcalPer100: 89, proteinPer100: 1.1, carbsPer100: 22.8, fatPer100: 0.3)
        ]

        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return [] }
        let q = query.lowercased()
        return all.filter { $0.name.lowercased().contains(q) }.prefix(30).map { $0 }
    }

    func toggleFavorite(foodId: UUID, isFavorite: Bool) async throws {
        // luego Supabase
    }
}

import Foundation

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast = "Desayuno"
    case lunch = "Comida"
    case dinner = "Cena"
    case snack = "Snack"

    var id: String { rawValue }
    var title: String { rawValue }
    var icon: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch: return "fork.knife"
        case .dinner: return "moon.stars"
        case .snack: return "takeoutbag.and.cup.and.straw"
        }
    }
}

struct MacroTargets: Codable, Equatable {
    var kcal: Int
    var protein: Int
    var carbs: Int
    var fat: Int

    static let `default` = MacroTargets(kcal: 2200, protein: 140, carbs: 250, fat: 70)
}

struct Food: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var brand: String?
    /// Valores por 100g
    var kcalPer100: Double
    var proteinPer100: Double
    var carbsPer100: Double
    var fatPer100: Double

    var isFavorite: Bool = false

    static let mock = Food(
        id: UUID(),
        name: "Avena",
        brand: "Genérico",
        kcalPer100: 389, proteinPer100: 16.9, carbsPer100: 66.3, fatPer100: 6.9
    )
}

struct MealItem: Identifiable, Codable, Equatable {
    var id: UUID
    var food: Food
    var grams: Double

    var kcal: Double { food.kcalPer100 * grams / 100.0 }
    var protein: Double { food.proteinPer100 * grams / 100.0 }
    var carbs: Double { food.carbsPer100 * grams / 100.0 }
    var fat: Double { food.fatPer100 * grams / 100.0 }
}

struct Meal: Identifiable, Codable, Equatable {
    var id: UUID
    var type: MealType
    var items: [MealItem]

    var kcal: Double { items.reduce(0) { $0 + $1.kcal } }
    var protein: Double { items.reduce(0) { $0 + $1.protein } }
    var carbs: Double { items.reduce(0) { $0 + $1.carbs } }
    var fat: Double { items.reduce(0) { $0 + $1.fat } }
}

struct WaterLog: Codable, Equatable {
    var ml: Int
    var goalML: Int

    static let `default` = WaterLog(ml: 0, goalML: 2500)
}

struct NutritionDay: Codable, Equatable {
    var date: Date
    var targets: MacroTargets
    var meals: [Meal]
    var water: WaterLog

    var totalKcal: Double { meals.reduce(0) { $0 + $1.kcal } }
    var totalProtein: Double { meals.reduce(0) { $0 + $1.protein } }
    var totalCarbs: Double { meals.reduce(0) { $0 + $1.carbs } }
    var totalFat: Double { meals.reduce(0) { $0 + $1.fat } }

    static func empty(date: Date, targets: MacroTargets = .default) -> NutritionDay {
        NutritionDay(
            date: date,
            targets: targets,
            meals: MealType.allCases.map { Meal(id: UUID(), type: $0, items: []) },
            water: .default
        )
    }
}

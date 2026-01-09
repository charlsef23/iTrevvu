import Foundation

enum MealType: String, CaseIterable, Identifiable {
    case desayuno = "Desayuno"
    case comida = "Comida"
    case cena = "Cena"
    case snacks = "Snacks"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .desayuno: return "sunrise.fill"
        case .comida: return "fork.knife"
        case .cena: return "moon.stars.fill"
        case .snacks: return "takeoutbag.and.cup.and.straw.fill"
        }
    }
}

struct FoodItem: Identifiable, Hashable {
    let id: UUID
    var name: String
    var brand: String?
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct LoggedFood: Identifiable, Hashable {
    let id: UUID
    var food: FoodItem
    var grams: Int
}

struct MealLog: Identifiable {
    let id: UUID
    var meal: MealType
    var items: [LoggedFood]

    var totalCalories: Int {
        items.reduce(0) { $0 + $1.food.calories * $1.grams / 100 }
    }
}

import SwiftUI

struct FoodSearchView: View {

    @State private var query: String = ""

    // demo foods
    private let foods: [FoodItem] = [
        .init(id: UUID(), name: "Avena", brand: nil, calories: 389, protein: 17, carbs: 66, fat: 7),
        .init(id: UUID(), name: "Pechuga de pollo", brand: nil, calories: 165, protein: 31, carbs: 0, fat: 4),
        .init(id: UUID(), name: "Plátano", brand: nil, calories: 89, protein: 1, carbs: 23, fat: 0),
        .init(id: UUID(), name: "Yogur griego", brand: "Natural", calories: 97, protein: 9, carbs: 4, fat: 5),
        .init(id: UUID(), name: "Arroz cocido", brand: nil, calories: 130, protein: 2, carbs: 28, fat: 0)
    ]

    private var filtered: [FoodItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return foods }
        return foods.filter { $0.name.localizedCaseInsensitiveContains(q) || ($0.brand?.localizedCaseInsensitiveContains(q) ?? false) }
    }

    var body: some View {
        List {
            Section("Resultados") {
                ForEach(filtered) { food in
                    NavigationLink {
                        FoodDetailView(food: food)
                    } label: {
                        FoodRow(food: food)
                    }
                }
            }
        }
        .navigationTitle("Buscar alimento")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Buscar por nombre…")
        .tint(NutritionBrand.red)
    }
}

private struct FoodRow: View {
    let food: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(food.name)
                .font(.subheadline.weight(.semibold))
            Text("\(food.calories) kcal · P \(food.protein)g · C \(food.carbs)g · G \(food.fat)g")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

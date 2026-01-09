import SwiftUI

struct FoodDetailView: View {
    let food: FoodItem
    @State private var grams: Int = 100
    @State private var selectedMeal: MealType = .comida

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(food.name)
                    .font(.title2.bold())
                if let brand = food.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Stepper("Cantidad: \(grams) g", value: $grams, in: 10...1000, step: 10)

                Picker("Comida", selection: $selectedMeal) {
                    ForEach(MealType.allCases) { meal in
                        Text(meal.rawValue).tag(meal)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(14)
            .background(NutritionBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text("Macros (aprox.)")
                    .font(.headline.bold())

                MacroLine(title: "Calorías", value: kcalFor(grams))
                MacroLine(title: "Proteína", value: gramsFor(food.protein))
                MacroLine(title: "Carbohidratos", value: gramsFor(food.carbs))
                MacroLine(title: "Grasas", value: gramsFor(food.fat))
            }
            .padding(14)
            .background(NutritionBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button {
                // aquí luego guardas en Supabase / estado global
            } label: {
                Label("Añadir a \(selectedMeal.rawValue)", systemImage: "plus")
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(NutritionBrand.red)

            Spacer()
        }
        .padding(16)
        .navigationTitle("Alimento")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NutritionBrand.red)
    }

    private func kcalFor(_ grams: Int) -> String {
        let v = food.calories * grams / 100
        return "\(v) kcal"
    }

    private func gramsFor(_ per100: Int) -> String {
        let v = per100 * grams / 100
        return "\(v) g"
    }
}

private struct MacroLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

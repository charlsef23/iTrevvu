import SwiftUI

struct FoodDetailView: View {
    let food: Food
    let meal: MealType
    let onAdd: (_ grams: Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var gramsText: String = "100"

    private var grams: Double { Double(gramsText) ?? 0 }

    private var kcal: Int { Int((food.kcalPer100 * grams / 100.0).rounded()) }
    private var protein: Int { Int((food.proteinPer100 * grams / 100.0).rounded()) }
    private var carbs: Int { Int((food.carbsPer100 * grams / 100.0).rounded()) }
    private var fat: Int { Int((food.fatPer100 * grams / 100.0).rounded()) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    headerCard

                    gramsCard

                    macrosCard

                    Button {
                        let g = max(0, grams)
                        guard g > 0 else { return }
                        onAdd(g)
                        dismiss()
                    } label: {
                        Text("Añadir a \(meal.title)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(NutritionBrand.red, in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
            }
            .navigationTitle("Alimento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(food.name)
                .font(.title2.bold())

            if let brand = food.brand, !brand.isEmpty {
                Text(brand)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Valores por 100g")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(NutritionBrand.pad)
        .background(NutritionBrand.cardStyle(), in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
    }

    private var gramsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cantidad")
                .font(.headline)

            HStack(spacing: 10) {
                TextField("Gramos", text: $gramsText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)

                Text("g")
                    .foregroundStyle(.secondary)

                Spacer()

                Button("+50") { bump(50) }
                    .buttonStyle(.bordered)

                Button("+100") { bump(100) }
                    .buttonStyle(.bordered)
            }
        }
        .padding(NutritionBrand.pad)
        .background(NutritionBrand.cardStyle(), in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
    }

    private var macrosCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Totales (\(Int(grams))g)")
                .font(.headline)

            HStack {
                MacroPill(title: "Kcal", value: "\(kcal)")
                MacroPill(title: "P", value: "\(protein)g")
                MacroPill(title: "C", value: "\(carbs)g")
                MacroPill(title: "G", value: "\(fat)g")
            }
        }
        .padding(NutritionBrand.pad)
        .background(NutritionBrand.cardStyle(), in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
    }

    private func bump(_ add: Double) {
        let current = Double(gramsText) ?? 0
        gramsText = String(Int(current + add))
    }
}

private struct MacroPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.tertiary, in: RoundedRectangle(cornerRadius: 14))
    }
}

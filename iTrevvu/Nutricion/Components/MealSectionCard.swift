import SwiftUI

struct MealSectionCard: View {
    let meal: Meal
    let onAdd: () -> Void
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(meal.type.title, systemImage: meal.type.icon)
                    .font(.headline)
                Spacer()
                Text("\(Int(meal.kcal)) kcal")
                    .font(.subheadline.bold())
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(NutritionBrand.red)
                }
                .buttonStyle(.plain)
            }

            if meal.items.isEmpty {
                Text("Añade alimentos para empezar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(meal.items.prefix(3)) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.food.name)
                                    .font(.subheadline.bold())
                                Text("\(Int(item.grams)) g • \(Int(item.kcal)) kcal")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }

                Button(action: onOpen) {
                    Text("Ver todo")
                        .font(.footnote.bold())
                        .foregroundStyle(NutritionBrand.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(NutritionBrand.pad)
        .background(NutritionBrand.cardStyle(), in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
    }
}

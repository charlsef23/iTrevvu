import SwiftUI

struct MealSectionCard: View {
    let meal: MealType
    let calories: Int
    let itemsCount: Int

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(NutritionBrand.red.opacity(0.12))
                Image(systemName: meal.systemImage)
                    .foregroundStyle(NutritionBrand.red)
                    .font(.headline.weight(.bold))
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.rawValue)
                    .font(.subheadline.weight(.semibold))
                Text("\(itemsCount) alimentos · \(calories) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(NutritionBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(NutritionBrand.red.opacity(0.08), lineWidth: 1)
        )
    }
}

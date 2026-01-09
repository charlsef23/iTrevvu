import SwiftUI

struct NutritionDaySummaryCard: View {
    let date: Date
    let calorieGoal: Int
    let caloriesEaten: Int

    var remaining: Int { max(calorieGoal - caloriesEaten, 0) }
    var progress: Double {
        guard calorieGoal > 0 else { return 0 }
        return min(Double(caloriesEaten) / Double(calorieGoal), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Resumen")
                        .font(.headline.bold())
                    Text(formatted(date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(remaining) kcal restantes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(NutritionBrand.red)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(NutritionBrand.red.opacity(0.10))
                    .clipShape(Capsule())
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Consumidas")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(caloriesEaten)")
                        .font(.title2.bold())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Objetivo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(calorieGoal)")
                        .font(.headline.bold())
                }
            }

            ProgressView(value: progress)
                .tint(NutritionBrand.red)
        }
        .padding(14)
        .background(NutritionBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: NutritionBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NutritionBrand.corner, style: .continuous)
                .strokeBorder(NutritionBrand.red.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: NutritionBrand.shadow, radius: 10, y: 6)
    }

    private func formatted(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "es_ES")
        fmt.dateFormat = "EEEE, d MMM"
        return fmt.string(from: date).capitalized
    }
}

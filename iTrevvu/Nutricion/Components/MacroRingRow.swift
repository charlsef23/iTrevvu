import SwiftUI

struct MacroRingRow: View {
    let protein: (current: Int, goal: Int)
    let carbs: (current: Int, goal: Int)
    let fat: (current: Int, goal: Int)

    var body: some View {
        HStack(spacing: 10) {
            MacroCard(title: "Proteína", value: "\(protein.current)g", goal: "\(protein.goal)g", progress: ratio(protein))
            MacroCard(title: "Carbo", value: "\(carbs.current)g", goal: "\(carbs.goal)g", progress: ratio(carbs))
            MacroCard(title: "Grasa", value: "\(fat.current)g", goal: "\(fat.goal)g", progress: ratio(fat))
        }
    }

    private func ratio(_ tuple: (current: Int, goal: Int)) -> Double {
        guard tuple.goal > 0 else { return 0 }
        return min(Double(tuple.current) / Double(tuple.goal), 1.0)
    }
}

private struct MacroCard: View {
    let title: String
    let value: String
    let goal: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(goal)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.headline.bold())

            ProgressView(value: progress)
                .tint(NutritionBrand.red)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NutritionBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(NutritionBrand.red.opacity(0.08), lineWidth: 1)
        )
    }
}

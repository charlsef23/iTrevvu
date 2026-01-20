import SwiftUI
import Combine

struct MacroRingRow: View {
    let kcal: Double, kcalTarget: Double
    let protein: Double, proteinTarget: Double
    let carbs: Double, carbsTarget: Double
    let fat: Double, fatTarget: Double

    var body: some View {
        HStack(spacing: 10) {
            MacroRing(title: "Kcal", value: kcal, target: kcalTarget, unit: "")
            MacroRing(title: "P", value: protein, target: proteinTarget, unit: "g")
            MacroRing(title: "C", value: carbs, target: carbsTarget, unit: "g")
            MacroRing(title: "G", value: fat, target: fatTarget, unit: "g")
        }
        .padding(NutritionBrand.pad)
        .background(NutritionBrand.cardStyle(), in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
    }
}

private struct MacroRing: View {
    let title: String
    let value: Double
    let target: Double
    let unit: String

    var progress: Double { target <= 0 ? 0 : min(value / target, 1) }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(.tertiary, lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(NutritionBrand.red, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Text("\(Int(value))\(unit)")
                        .font(.caption.bold())
                }
            }
            .frame(width: 52, height: 52)

            Text("\(Int(target))\(unit)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

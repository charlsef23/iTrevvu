import SwiftUI

struct WaterCard: View {
    @Binding var waterML: Int
    let goalML: Int

    private var progress: Double {
        guard goalML > 0 else { return 0 }
        return min(Double(waterML) / Double(goalML), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(NutritionBrand.red.opacity(0.12))
                        Image(systemName: "drop.fill")
                            .foregroundStyle(NutritionBrand.red)
                    }
                    .frame(width: 38, height: 38)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Agua")
                            .font(.headline.bold())
                        Text("\(waterML) / \(goalML) ml")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button {
                    waterML = max(0, waterML - 250)
                } label: {
                    Image(systemName: "minus")
                        .font(.subheadline.weight(.bold))
                }
                .buttonStyle(.bordered)
                .tint(NutritionBrand.red)

                Button {
                    waterML += 250
                } label: {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(NutritionBrand.red)
            }

            ProgressView(value: progress)
                .tint(NutritionBrand.red)
        }
        .padding(14)
        .background(NutritionBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: NutritionBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NutritionBrand.corner, style: .continuous)
                .strokeBorder(NutritionBrand.red.opacity(0.10), lineWidth: 1)
        )
    }
}

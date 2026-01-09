import SwiftUI

struct StatsPreviewCard: View {

    struct Metric: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let systemImage: String
    }

    let title: String
    let subtitle: String
    let metrics: [Metric]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.bold())
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                ForEach(metrics) { m in
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: m.systemImage)
                            .foregroundStyle(NutritionBrand.red)
                        Text(m.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(m.value)
                            .font(.subheadline.bold())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(NutritionBrand.red.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
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

import SwiftUI

struct ExerciseStatsPreviewCard: View {

    private let accent = TrainingBrand.stats

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Resumen")
                        .font(.headline.bold())
                    Text("Últimos 30 días")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Ver más")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)
            }

            HStack(spacing: 10) {
                StatMini(title: "Volumen", value: "12.4K kg", icon: "scalemass.fill", tint: accent)
                StatMini(title: "Sesiones", value: "18", icon: "figure.strengthtraining.traditional", tint: accent)
                StatMini(title: "PRs", value: "3", icon: "medal.fill", tint: accent)
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 7, y: 4)
    }
}

private struct StatMini: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(TrainingBrand.softFill(tint))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

import SwiftUI

struct ExerciseStatsPreviewCard: View {

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
                    .foregroundStyle(TrainingBrand.stats)
            }

            HStack(spacing: 10) {
                StatMini(
                    title: "Volumen",
                    value: "12.4K kg",
                    icon: "scalemass.fill",
                    tint: TrainingBrand.stats
                )
                StatMini(
                    title: "Sesiones",
                    value: "18",
                    icon: "figure.strengthtraining.traditional",
                    tint: TrainingBrand.stats
                )
                StatMini(
                    title: "PRs",
                    value: "3",
                    icon: "medal.fill",
                    tint: TrainingBrand.stats
                )
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.stats.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
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
        .background(
            tint.opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

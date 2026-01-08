import SwiftUI

struct ExerciseStatsPreviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    .foregroundStyle(TrainingBrand.red)
            }

            HStack(spacing: 10) {
                StatMini(title: "Volumen", value: "12.4K kg", icon: "scalemass.fill")
                StatMini(title: "Sesiones", value: "18", icon: "figure.strengthtraining.traditional")
                StatMini(title: "PRs", value: "3", icon: "medal.fill")
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.red.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct StatMini: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(TrainingBrand.red)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(TrainingBrand.red.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

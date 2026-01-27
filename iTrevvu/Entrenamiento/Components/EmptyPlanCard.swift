import SwiftUI

struct EmptyPlanCard: View {

    let onPlan: () -> Void

    var body: some View {
        Button(action: onPlan) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(TrainingBrand.softFill(TrainingBrand.stats))
                    Image(systemName: "calendar.badge.plus")
                        .font(.headline.bold())
                        .foregroundStyle(TrainingBrand.stats)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Sin sesión planificada")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("Toca para planificar tu entrenamiento de hoy")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(TrainingBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner))
            .overlay(
                RoundedRectangle(cornerRadius: TrainingBrand.corner)
                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

struct PlannedWorkoutDayCard: View {

    let plan: TrainingPlan
    let onTrain: () -> Void
    let onEdit: () -> Void

    var body: some View {
        let accent = accentColor(plan.kind)

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.12))
                    Image(systemName: icon(plan.kind))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan de hoy")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(title(plan))
                        .font(.headline.bold())
                }

                Spacer()

                Button("Editar") { onEdit() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
                    .buttonStyle(.plain)
            }

            if let mins = plan.durationMinutes {
                Text("Duración: \(mins) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let note = plan.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Button(action: onTrain) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Entrenar ahora")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(accent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private func title(_ plan: TrainingPlan) -> String {
        if plan.kind == .rutina, let r = plan.routineTitle { return r }
        return plan.kind.title
    }

    private func icon(_ kind: TrainingPlanKind) -> String {
        switch kind {
        case .gimnasio: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        case .rutina: return "list.bullet.rectangle.portrait"
        }
    }

    private func accentColor(_ kind: TrainingPlanKind) -> Color {
        switch kind {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        case .rutina: return TrainingBrand.custom
        }
    }
}

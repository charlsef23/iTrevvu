import SwiftUI

struct PlannedWorkoutDayCard: View {

    let plan: PlannedSession
    let onTrain: () -> Void
    let onEdit: () -> Void

    var body: some View {
        let accent = accentColor(plan.tipo)

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.12))
                    Image(systemName: icon(plan.tipo))
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

            if let mins = plan.duracionMinutos {
                Text("Duración: \(mins) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let note = plan.notas, !note.isEmpty {
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

    private func title(_ plan: PlannedSession) -> String {
        // Si el usuario puso nombre, lo usamos; si no, usamos el tipo
        let trimmed = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        return plan.tipo.title
    }

    private func icon(_ tipo: TrainingSessionType) -> String {
        // Si guardas icono en BD lo priorizamos, pero aquí usamos el tipo para consistencia
        switch tipo {
        case .gimnasio: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        case .rutina: return "list.bullet.rectangle.portrait"
        case .hiit: return "bolt.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .deporte: return "sportscourt.fill"
        case .rehab: return "cross.case.fill"
        case .descanso: return "bed.double.fill"
        }
    }

    private func accentColor(_ tipo: TrainingSessionType) -> Color {
        switch tipo {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        case .rutina: return TrainingBrand.custom
        case .hiit: return TrainingBrand.cardio
        case .calistenia: return TrainingBrand.action
        case .deporte: return TrainingBrand.custom
        case .rehab: return TrainingBrand.mobility
        case .descanso: return .secondary
        }
    }
}

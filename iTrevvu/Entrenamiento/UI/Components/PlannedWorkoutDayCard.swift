import SwiftUI
import Foundation

struct PlannedWorkoutDayCard: View {

    let plan: PlannedSession
    let onTrain: () -> Void
    let onEdit: () -> Void

    var body: some View {
        let accent = accentForType(plan.tipo)

        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.12))

                    Image(systemName: iconForType(plan.tipo))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan de hoy")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(titleForPlan(plan))
                        .font(.headline.bold())
                        .lineLimit(1)
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

            if let note = plan.notas,
               !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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

    private func titleForPlan(_ plan: PlannedSession) -> String {
        let trimmed = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? plan.tipo.title : trimmed
    }

    private func iconForType(_ t: TrainingSessionType) -> String {
        switch t {
        case .gimnasio: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        case .rutina: return "list.bullet.rectangle"
        case .hiit: return "bolt.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .deporte: return "sportscourt.fill"
        case .rehab: return "cross.case.fill"
        case .descanso: return "bed.double.fill"
        }
    }

    private func accentForType(_ t: TrainingSessionType) -> Color {
        switch t {
        case .gimnasio, .calistenia:
            return TrainingBrand.action
        case .cardio, .hiit:
            return TrainingBrand.cardio
        case .movilidad, .rehab, .descanso:
            return TrainingBrand.mobility
        case .rutina, .deporte:
            return TrainingBrand.custom
        }
    }
}

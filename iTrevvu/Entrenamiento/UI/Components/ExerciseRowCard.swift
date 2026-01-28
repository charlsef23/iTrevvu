import SwiftUI

struct ExerciseRowCard: View {
    let ex: Exercise
    let isFavorite: Bool
    let onFavorite: () -> Void

    // opcional: para modo “seleccionar ejercicio”
    var trailingChevron: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {

                let isPersonal = (ex.autor_id != nil)
                let tint = isPersonal ? TrainingBrand.custom : TrainingBrand.action

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(TrainingBrand.softFill(tint))

                    Image(systemName: iconFor(ex))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(tint)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ex.nombre)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitleFor(ex))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? TrainingBrand.stats : .secondary)
                }
                .buttonStyle(.plain)

                if trailingChevron {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 6)
                }
            }
            .padding(12)
            .background(TrainingBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func subtitleFor(_ ex: Exercise) -> String {
        let muscle = (ex.musculo_principal ?? "—")
        return "\(muscle) · \(ex.tipo_medicion.title)"
    }

    private func iconFor(_ ex: Exercise) -> String {
        // Si tu Exercise.tipo es enum ExerciseType, esto compila tal cual.
        // Si fuera String, dímelo y lo adapto.
        switch ex.tipo {
        case .fuerza: return "dumbbell.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .cardio: return "figure.run"
        case .hiit: return "bolt.fill"
        case .core: return "circle.grid.cross"
        case .movilidad: return "figure.cooldown"
        case .rehab: return "cross.case.fill"
        case .deporte: return "sportscourt"
        case .rutinas: return "list.bullet.rectangle"
        }
    }
}

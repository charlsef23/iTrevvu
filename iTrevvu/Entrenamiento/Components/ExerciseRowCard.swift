import SwiftUI

struct ExerciseRowCard: View {
    let ex: Exercise
    let isSelected: Bool
    let showSelection: Bool
    let onFav: () -> Void
    let isFav: Bool

    var body: some View {
        let isPersonal = (ex.autor_id != nil)
        let accent = isPersonal ? TrainingBrand.custom : TrainingBrand.action

        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(TrainingBrand.softFill(accent))

                Image(systemName: ex.tipo.icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(ex.nombre)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(ex.tipo.title + (isPersonal ? " · Personal" : ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onFav) {
                Image(systemName: isFav ? "heart.fill" : "heart")
                    .foregroundStyle(isFav ? TrainingBrand.stats : .secondary)
            }
            .buttonStyle(.plain)

            if showSelection {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.headline)
                    .foregroundStyle(isSelected ? TrainingBrand.stats : .secondary.opacity(0.7))
                    .padding(.leading, 4)
            } else {
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
                .strokeBorder(isSelected ? TrainingBrand.stats.opacity(0.45) : TrainingBrand.separator, lineWidth: 1)
        )
    }
}

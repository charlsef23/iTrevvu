import SwiftUI

struct RoutineCard: View {
    let title: String
    let subtitle: String
    let tag: String?

    private let accent = TrainingBrand.custom

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let tag {
                    Text(tag)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accent)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(TrainingBrand.softFill(accent))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }
}

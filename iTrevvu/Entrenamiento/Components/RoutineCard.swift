import SwiftUI

struct RoutineCard: View {
    let title: String
    let subtitle: String
    let tag: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
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
                        .foregroundStyle(TrainingBrand.red)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(TrainingBrand.red.opacity(0.10))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(TrainingBrand.red.opacity(0.08), lineWidth: 1)
        )
    }
}

import SwiftUI

struct ActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(TrainingBrand.softFill(accent))

                Image(systemName: icon)
                    .font(.headline.bold())
                    .foregroundStyle(accent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.bold())

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }
}

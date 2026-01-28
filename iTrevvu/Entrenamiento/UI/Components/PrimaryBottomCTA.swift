import SwiftUI

struct PrimaryBottomCTA: View {

    let title: String
    let subtitle: String
    let systemImage: String
    let isEnabled: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {

                ZStack {
                    Circle()
                        .fill(accent.opacity(0.15))

                    Image(systemName: systemImage)
                        .font(.headline.bold())
                        .foregroundStyle(accent)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.bold())

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(TrainingBrand.card)
            .opacity(isEnabled ? 1 : 0.4)
            .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner))
            .overlay(
                RoundedRectangle(cornerRadius: TrainingBrand.corner)
                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

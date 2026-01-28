import SwiftUI

struct TrainingBottomCTA: View {

    let title: String
    let subtitle: String
    let systemImage: String
    let isEnabled: Bool
    let accent: Color
    let action: () -> Void

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        isEnabled: Bool = true,
        accent: Color,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isEnabled = isEnabled
        self.accent = accent
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {

                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(accent))

                    Image(systemName: systemImage)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accent)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(TrainingBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
            )
            .opacity(isEnabled ? 1.0 : 0.45)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

import SwiftUI

struct SettingsSectionCard<Content: View>: View {

    // ✅ En genéricos: usar computed static vars (no stored)
    private enum Brand {
        static var red: Color { .red }
        static var card: Color { Color(.secondarySystemBackground) }
        static var corner: CGFloat { 16 }
    }

    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)

            VStack(spacing: 0) {
                content
            }
            .background(Brand.card)
            .clipShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .strokeBorder(Brand.red.opacity(0.10), lineWidth: 1)
            )
        }
    }
}

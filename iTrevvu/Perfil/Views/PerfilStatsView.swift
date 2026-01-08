import SwiftUI

struct PerfilStatsView: View {

    private enum Brand {
        static let red = Color.red
        static let card = Color(.secondarySystemBackground)
        static let corner: CGFloat = 18
    }

    struct StatItem: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        var action: (() -> Void)? = nil
    }

    let stats: [StatItem]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(stats) { item in
                Button {
                    item.action?()
                } label: {
                    VStack(spacing: 6) {
                        Text(item.value)
                            .font(.headline.bold())
                            .foregroundStyle(.primary)

                        Text(item.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Brand.card)
                    .clipShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                            .strokeBorder(Brand.red.opacity(0.10), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

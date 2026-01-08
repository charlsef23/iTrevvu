import SwiftUI

struct PerfilQuickGridView: View {

    private enum Brand {
        static let red = Color.red
        static let card = Color(.secondarySystemBackground)
        static let corner: CGFloat = 18
    }

    struct QuickItem: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
    }

    let items: [QuickItem]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items) { item in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Brand.red.opacity(0.12))
                        Image(systemName: item.systemImage)
                            .font(.headline)
                            .foregroundStyle(Brand.red)
                    }
                    .frame(width: 38, height: 38)

                    Text(item.title)
                        .font(.subheadline.weight(.semibold))

                    Spacer()
                }
                .padding(14)
                .background(Brand.card)
                .clipShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                        .strokeBorder(Brand.red.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }
}

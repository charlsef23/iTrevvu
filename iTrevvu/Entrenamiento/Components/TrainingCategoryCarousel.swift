import SwiftUI

struct TrainingCategoryCarousel: View {

    struct Item: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let systemImage: String
        let tint: Color
        let destination: AnyView
    }

    let items: [Item]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    NavigationLink {
                        item.destination
                    } label: {
                        CategoryCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
        }
    }
}

private struct CategoryCard: View {

    let item: TrainingCategoryCarousel.Item

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Icono protagonista
            HStack {
                ZStack {
                    Circle()
                        .fill(item.tint.opacity(0.12))
                    Image(systemName: item.systemImage)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(item.tint)
                }
                .frame(width: 52, height: 52)

                Spacer()
            }

            // Texto
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            // Barra de significado
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(item.tint.opacity(0.75))
                .frame(height: 4)
                .padding(.top, 4)
        }
        .padding(14)
        .frame(width: 240, height: 150)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        // Sin sombras a propósito
    }
}

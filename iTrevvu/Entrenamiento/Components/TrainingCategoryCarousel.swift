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
                        CategoryCard(
                            title: item.title,
                            subtitle: item.subtitle,
                            systemImage: item.systemImage,
                            tint: item.tint
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct CategoryCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.12))
                Image(systemName: systemImage)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(tint)
            }
            .frame(width: 48, height: 48)

            Text(title)
                .font(.headline.bold())

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer(minLength: 0)

            HStack {
                Text("Abrir")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tint)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(width: 240, height: 160)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(tint.opacity(0.10), lineWidth: 1)
        )
    }
}

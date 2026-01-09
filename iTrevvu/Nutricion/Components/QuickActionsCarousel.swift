import SwiftUI

struct QuickActionsCarousel: View {

    struct Item: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let systemImage: String
        let action: () -> Void
    }

    let items: [Item]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items) { item in
                    Button(action: item.action) {
                        QuickActionCard(
                            title: item.title,
                            subtitle: item.subtitle,
                            systemImage: item.systemImage
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(NutritionBrand.red.opacity(0.12))
                Image(systemName: systemImage)
                    .foregroundStyle(NutritionBrand.red)
                    .font(.headline.weight(.bold))
            }
            .frame(width: 46, height: 46)

            Text(title)
                .font(.subheadline.bold())

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(width: 210, height: 140)
        .background(NutritionBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: NutritionBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NutritionBrand.corner, style: .continuous)
                .strokeBorder(NutritionBrand.red.opacity(0.10), lineWidth: 1)
        )
    }
}

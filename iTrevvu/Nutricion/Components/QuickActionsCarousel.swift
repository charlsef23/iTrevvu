import SwiftUI

struct QuickActionsCarousel: View {
    let onAddFood: () -> Void
    let onAddWater: () -> Void
    let onOpenStats: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                QuickActionCard(title: "Añadir comida", icon: "plus", tint: NutritionBrand.red, action: onAddFood)
                QuickActionCard(title: "Añadir agua", icon: "drop.fill", tint: NutritionBrand.red, action: onAddWater)
                QuickActionCard(title: "Estadísticas", icon: "chart.line.uptrend.xyaxis", tint: NutritionBrand.red, action: onOpenStats)
            }
            .padding(.vertical, 2)
        }
    }
}

private struct QuickActionCard: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(tint, in: RoundedRectangle(cornerRadius: 12))
                Text(title)
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding(12)
            .frame(width: 220)
            .background(NutritionBrand.cardStyle(), in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
        }
        .buttonStyle(.plain)
    }
}

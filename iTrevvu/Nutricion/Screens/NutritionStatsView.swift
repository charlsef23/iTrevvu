import SwiftUI

struct NutritionStatsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                StatsBlock(title: "Calorías", subtitle: "Tendencia 30 días", icon: "flame.fill")
                StatsBlock(title: "Macros", subtitle: "Cumplimiento semanal", icon: "chart.pie.fill")
                StatsBlock(title: "Agua", subtitle: "Media diaria", icon: "drop.fill")
                StatsBlock(title: "Peso", subtitle: "Evolución (opcional)", icon: "scalemass.fill")
            }
            .padding(16)
        }
        .navigationTitle("Estadísticas")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NutritionBrand.red)
    }
}

private struct StatsBlock: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(NutritionBrand.red.opacity(0.12))
                    Image(systemName: icon)
                        .foregroundStyle(NutritionBrand.red)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline.bold())
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }

            Text("Aquí irá la gráfica / datos reales (pendiente).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(NutritionBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: NutritionBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NutritionBrand.corner, style: .continuous)
                .strokeBorder(NutritionBrand.red.opacity(0.10), lineWidth: 1)
        )
    }
}

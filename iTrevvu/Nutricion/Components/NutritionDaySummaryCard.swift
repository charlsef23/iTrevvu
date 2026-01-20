import SwiftUI

struct NutritionDaySummaryCard: View {
    let day: NutritionDay

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedDate(day.date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Resumen del día")
                        .font(.title3.bold())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(day.totalKcal)) / \(day.targets.kcal)")
                        .font(.headline.bold())
                    Text("kcal")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: day.totalKcal, total: Double(day.targets.kcal))
        }
        .padding(NutritionBrand.pad)
        .background(NutritionBrand.cardStyle(), in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateStyle = .full
        return f.string(from: date).capitalized
    }
}

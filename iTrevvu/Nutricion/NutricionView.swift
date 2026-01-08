import SwiftUI

struct NutricionView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 8) {
                        Text("Calorías de hoy")
                            .font(.headline)
                        Text("1.850 / 2.300 kcal")
                            .font(.title.bold())
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)

                    HStack(spacing: 12) {
                        MacroCard(title: "Proteínas", value: "120g")
                        MacroCard(title: "Carbos", value: "180g")
                        MacroCard(title: "Grasas", value: "60g")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comidas")
                            .font(.title3.bold())

                        ForEach(["Desayuno", "Comida", "Cena"], id: \.self) { meal in
                            MealRow(title: meal)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Nutrición")
        }
    }
}

private struct MacroCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

private struct MealRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("— kcal")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}

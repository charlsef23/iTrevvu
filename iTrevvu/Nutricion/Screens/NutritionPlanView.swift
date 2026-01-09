import SwiftUI

struct NutritionPlanView: View {
    var body: some View {
        List {
            Section("Objetivos") {
                Row(title: "Calorías", value: "2300 kcal", icon: "flame.fill")
                Row(title: "Proteína", value: "160 g", icon: "bolt.fill")
                Row(title: "Carbohidratos", value: "240 g", icon: "leaf.fill")
                Row(title: "Grasas", value: "70 g", icon: "drop.triangle.fill")
            }

            Section("Plan semanal") {
                Text("Aquí irá tu plan (pendiente).")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Plan")
        .tint(NutritionBrand.red)
    }
}

private struct Row: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(NutritionBrand.red)
                .frame(width: 22)
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

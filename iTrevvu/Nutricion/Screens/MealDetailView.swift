import SwiftUI

struct MealDetailView: View {
    let meal: MealType

    var body: some View {
        VStack(spacing: 14) {
            Text("Aquí verás los alimentos de \(meal.rawValue).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                AddFoodToMealView(meal: meal)
            } label: {
                Label("Añadir alimento", systemImage: "plus")
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(NutritionBrand.red)

            Spacer()
        }
        .padding(16)
        .navigationTitle(meal.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

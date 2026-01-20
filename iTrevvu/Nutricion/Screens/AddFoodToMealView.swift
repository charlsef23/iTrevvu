import SwiftUI

struct AddFoodToMealView: View {
    let meal: MealType
    let onPick: (Food) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Añadir a \(meal.title)")
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                FoodSearchView(meal: meal, onPick: onPick)
            } label: {
                Label("Buscar en alimentos", systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(NutritionBrand.red)

            Spacer()
        }
        .padding(16)
        .navigationTitle("Añadir")
        .navigationBarTitleDisplayMode(.inline)
    }
}

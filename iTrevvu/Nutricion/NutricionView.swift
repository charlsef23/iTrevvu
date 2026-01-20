import SwiftUI

struct NutricionView: View {
    @StateObject private var store = NutritionStore()

    @State private var showFoodSearch = false
    @State private var selectedMeal: MealType = .lunch

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    NutritionDaySummaryCard(day: store.day)

                    MacroRingRow(
                        kcal: store.day.totalKcal, kcalTarget: Double(store.day.targets.kcal),
                        protein: store.day.totalProtein, proteinTarget: Double(store.day.targets.protein),
                        carbs: store.day.totalCarbs, carbsTarget: Double(store.day.targets.carbs),
                        fat: store.day.totalFat, fatTarget: Double(store.day.targets.fat)
                    )

                    WaterCard(
                        water: store.day.water,
                        onAdd: { ml in Task { await store.addWater(ml: ml) } },
                        onSetGoal: { goal in Task { await store.setWaterGoal(goal) } }
                    )

                    QuickActionsCarousel(
                        onAddFood: {
                            selectedMeal = .lunch
                            showFoodSearch = true
                        },
                        onAddWater: { Task { await store.addWater(ml: 250) } },
                        onOpenStats: { /* navega a stats */ }
                    )

                    ForEach(store.day.meals) { meal in
                        MealSectionCard(
                            meal: meal,
                            onAdd: {
                                selectedMeal = meal.type
                                showFoodSearch = true
                            },
                            onOpen: {
                                // Navegación a detalle
                            }
                        )
                    }

                    if let err = store.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
            }
            .background(NutritionBrand.bg)
            .navigationTitle("Nutrición")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedMeal = .lunch
                        showFoodSearch = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(NutritionBrand.red)
                    }
                }
            }
            .task { await store.loadDay(Date()) }
            .refreshable { await store.loadDay(Date()) }
            .sheet(isPresented: $showFoodSearch) {
                FoodSearchView(
                    meal: selectedMeal,
                    onPick: { food in
                        // Abre detalle para gramos/ración (más pro)
                        // Para simplificar: añadimos 100g por defecto
                        Task { await store.addFood(food, grams: 100, to: selectedMeal) }
                        showFoodSearch = false
                    }
                )
            }
        }
    }
}

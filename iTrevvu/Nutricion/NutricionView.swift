import SwiftUI

struct NutricionView: View {

    @State private var selectedDate: Date = .now

    // Estado demo (luego lo conectas a datos reales)
    @State private var calorieGoal: Int = 2300
    @State private var caloriesEaten: Int = 1250

    @State private var proteinGoal: Int = 160
    @State private var carbsGoal: Int = 240
    @State private var fatGoal: Int = 70

    @State private var proteinEaten: Int = 92
    @State private var carbsEaten: Int = 130
    @State private var fatEaten: Int = 38

    @State private var waterGoalML: Int = 2500
    @State private var waterML: Int = 1100

    @State private var meals: [MealLog] = [
        MealLog(id: UUID(), meal: .desayuno, items: []),
        MealLog(id: UUID(), meal: .comida, items: []),
        MealLog(id: UUID(), meal: .cena, items: []),
        MealLog(id: UUID(), meal: .snacks, items: [])
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    NutritionDaySummaryCard(
                        date: selectedDate,
                        calorieGoal: calorieGoal,
                        caloriesEaten: caloriesEaten
                    )

                    MacroRingRow(
                        protein: (proteinEaten, proteinGoal),
                        carbs: (carbsEaten, carbsGoal),
                        fat: (fatEaten, fatGoal)
                    )

                    QuickActionsCarousel(items: [
                        .init(title: "Buscar alimento", subtitle: "Base de datos", systemImage: "magnifyingglass") {
                            // Navega con NavigationLink en el HUB (abajo)
                        },
                        .init(title: "Escanear", subtitle: "Código de barras", systemImage: "barcode.viewfinder") { },
                        .init(title: "Recetas", subtitle: "Ideas rápidas", systemImage: "book.closed") { },
                        .init(title: "Plan semanal", subtitle: "Objetivos", systemImage: "calendar") { }
                    ])

                    // Accesos reales (con navegación)
                    HStack(spacing: 12) {
                        NavigationLink { FoodSearchView() } label: {
                            Label("Buscar", systemImage: "magnifyingglass")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(NutritionBrand.red)

                        NavigationLink { NutritionPlanView() } label: {
                            Label("Plan", systemImage: "calendar")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(NutritionBrand.red)
                    }

                    WaterCard(waterML: $waterML, goalML: waterGoalML)

                    SectionHeader(title: "Comidas", actionTitle: "Ver día") {
                        // opcional: pantalla calendario detalle
                    }

                    VStack(spacing: 12) {
                        ForEach(meals) { mealLog in
                            NavigationLink {
                                MealDetailView(meal: mealLog.meal)
                            } label: {
                                MealSectionCard(
                                    meal: mealLog.meal,
                                    calories: mealLog.totalCalories,
                                    itemsCount: mealLog.items.count
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    SectionHeader(title: "Estadísticas", actionTitle: "Ver estadísticas") { }

                    NavigationLink { NutritionStatsView() } label: {
                        StatsPreviewCard(
                            title: "Cumplimiento semanal",
                            subtitle: "Calorías y macros · últimos 7 días",
                            metrics: [
                                .init(title: "Días en objetivo", value: "4/7", systemImage: "checkmark.seal.fill"),
                                .init(title: "Promedio kcal", value: "2.1K", systemImage: "flame.fill"),
                                .init(title: "Agua", value: "1.8L", systemImage: "drop.fill")
                            ]
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(NutritionBrand.bg)
            .navigationTitle("Nutrición")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { FoodSearchView() } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(NutritionBrand.red)
                    }
                }
            }
            .tint(NutritionBrand.red)
        }
    }
}

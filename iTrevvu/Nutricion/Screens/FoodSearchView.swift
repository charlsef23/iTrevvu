import SwiftUI

struct FoodSearchView: View {
    let meal: MealType
    let onPick: (Food) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [Food] = []
    @State private var isLoading = false

    private let service: NutritionServiceProtocol = NutritionService()

    var body: some View {
        NavigationStack {
            List {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Section("Sugerencias") {
                        Button {
                            onPick(.mock)
                        } label: {
                            Label("Avena", systemImage: "sparkles")
                        }
                    }
                } else {
                    Section {
                        if isLoading {
                            HStack { Spacer(); ProgressView(); Spacer() }
                        } else if results.isEmpty {
                            Text("No hay resultados.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(results) { food in
                                Button {
                                    onPick(food)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(food.name).font(.headline)
                                        Text("100g • \(Int(food.kcalPer100)) kcal")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Resultados")
                    }
                }
            }
            .navigationTitle("Añadir a \(meal.title)")
            .searchable(text: $query, prompt: "Buscar alimento")
            .onChange(of: query) { _, newValue in
                Task { await searchDebounced(newValue) }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    private func searchDebounced(_ text: String) async {
        isLoading = true
        let current = text
        try? await Task.sleep(nanoseconds: 280_000_000) // 280ms debounce
        guard current == query else { return }

        do {
            results = try await service.searchFoods(query: current)
        } catch {
            results = []
        }
        isLoading = false
    }
}

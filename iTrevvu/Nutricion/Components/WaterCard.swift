import SwiftUI

struct WaterCard: View {
    let water: WaterLog
    let onAdd: (Int) -> Void
    let onSetGoal: (Int) -> Void

    @State private var showGoalSheet = false
    @State private var goalText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Agua", systemImage: "drop.fill")
                    .font(.headline)
                Spacer()
                Button("Meta") {
                    goalText = "\(water.goalML)"
                    showGoalSheet = true
                }
                .font(.footnote.bold())
                .foregroundStyle(NutritionBrand.red)
                .buttonStyle(.plain)
            }

            ProgressView(value: Double(water.ml), total: Double(max(water.goalML, 1)))
            HStack {
                Text("\(water.ml) / \(water.goalML) ml")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("+250") { onAdd(250) }
                    .buttonStyle(.bordered)
                Button("+500") { onAdd(500) }
                    .buttonStyle(.bordered)
            }
        }
        .padding(NutritionBrand.pad)
        .background(NutritionBrand.cardStyle(), in: RoundedRectangle(cornerRadius: NutritionBrand.corner))
        .sheet(isPresented: $showGoalSheet) {
            NavigationStack {
                Form {
                    TextField("Meta (ml)", text: $goalText)
                        .keyboardType(.numberPad)
                }
                .navigationTitle("Meta de agua")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancelar") { showGoalSheet = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Guardar") {
                            let goal = Int(goalText) ?? water.goalML
                            onSetGoal(goal)
                            showGoalSheet = false
                        }
                        .foregroundStyle(NutritionBrand.red)
                    }
                }
            }
        }
    }
}

import SwiftUI

struct CreateCustomExerciseView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ExerciseStore

    @State private var name = ""
    @State private var category: ExerciseCategory = .fuerza
    @State private var primary: MuscleGroup = .pecho
    @State private var equipment: Equipment = .mancuernas
    @State private var pattern: MovementPattern = .aislamiento
    @State private var repRange = "8–12"
    @State private var note = ""

    var body: some View {
        Form {
            Section("Nombre") {
                TextField("Ej: Press banca con pausa", text: $name)
            }

            Section("Clasificación") {
                Picker("Categoría", selection: $category) {
                    ForEach(ExerciseCategory.allCases) { Text($0.title).tag($0) }
                }
                Picker("Músculo principal", selection: $primary) {
                    ForEach(MuscleGroup.allCases) { Text($0.title).tag($0) }
                }
                Picker("Equipo", selection: $equipment) {
                    ForEach(Equipment.allCases) { Text($0.title).tag($0) }
                }
                Picker("Patrón", selection: $pattern) {
                    ForEach(MovementPattern.allCases) { Text($0.title).tag($0) }
                }
            }

            Section("Opcional") {
                TextField("Rango reps/tiempo", text: $repRange)
                TextField("Tips / notas", text: $note, axis: .vertical)
                    .lineLimit(2...5)
            }
        }
        .navigationTitle("Nuevo ejercicio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    let ex = Exercise(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        category: category,
                        primary: primary,
                        secondary: [],
                        equipment: [equipment],
                        pattern: pattern,
                        isUnilateral: false,
                        isBodyweight: equipment == .pesoCorporal,
                        defaultRepRange: repRange.isEmpty ? nil : repRange,
                        tips: note.isEmpty ? nil : note,
                        isCustom: true
                    )
                    store.addCustom(ex)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

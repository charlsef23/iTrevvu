import SwiftUI

struct CreateCustomExerciseView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ExerciseStore

    private let accent = TrainingBrand.action

    @State private var name: String = ""
    @State private var category: ExerciseCategory = .fuerza
    @State private var primary: MuscleGroup = .fullBody
    @State private var pattern: MovementPattern = .aislamiento
    @State private var equipment: Equipment? = nil

    @State private var isUnilateral: Bool = false
    @State private var isBodyweight: Bool = false
    @State private var repRange: String = "8–12"
    @State private var tips: String = ""

    @State private var isSaving = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {

                SportHeroCard(
                    title: "Nuevo ejercicio",
                    subtitle: "Añádelo a tu biblioteca",
                    icon: "plus.circle.fill",
                    accent: accent
                )

                card(title: "Básico") {
                    field(title: "Nombre", placeholder: "Ej: Press banca con pausa", text: $name)

                    PickerRow(title: "Categoría") {
                        Picker("", selection: $category) {
                            ForEach(ExerciseCategory.allCases, id: \.self) { c in
                                Text(c.title).tag(c)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    PickerRow(title: "Músculo principal") {
                        Picker("", selection: $primary) {
                            ForEach(MuscleGroup.allCases, id: \.self) { m in
                                Text(m.title).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                card(title: "Detalles") {
                    PickerRow(title: "Patrón") {
                        Picker("", selection: $pattern) {
                            ForEach(MovementPattern.allCases, id: \.self) { p in
                                Text(p.title).tag(p)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    PickerRow(title: "Equipo") {
                        Picker("", selection: $equipment) {
                            Text("Sin equipo").tag(Equipment?.none)
                            ForEach(Equipment.allCases, id: \.self) { e in
                                Text(e.title).tag(Optional(e))
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Toggle("Unilateral", isOn: $isUnilateral)
                    Toggle("Peso corporal", isOn: $isBodyweight)

                    field(title: "Rango reps (default)", placeholder: "Ej: 6–10", text: $repRange)
                    field(title: "Tips", placeholder: "Cues, técnica…", text: $tips, axis: .vertical)
                }

                Button {
                    // ✅ FIX: Task para poder usar await
                    Task { await save() }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(isSaving ? "Guardando…" : "Guardar")
                            .font(.headline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isSaving || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Crear ejercicio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar") { dismiss() }
            }
        }
        .tint(.primary)
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let ex = Exercise(
            id: UUID(),
            name: trimmed,
            category: category,
            primary: primary,
            secondary: [],
            equipment: equipment.map { [$0] } ?? [],
            pattern: pattern,
            isUnilateral: isUnilateral,
            isBodyweight: isBodyweight,
            defaultRepRange: repRange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : repRange,
            tips: tips.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tips,
            isCustom: true
        )

        await store.addCustom(ex)
        dismiss()
    }

    // MARK: - UI helpers

    private func card(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.bold())

            content()
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private func field(title: String, placeholder: String, text: Binding<String>, axis: Axis = .horizontal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text, axis: axis)
                .lineLimit(axis == .vertical ? 2...5 : 1...1)
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

private struct PickerRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Spacer()
            content
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

import SwiftUI

struct CrearRutinaView: View {

    private let accent = TrainingBrand.custom

    @Environment(\.dismiss) private var dismiss

    // ✅ FIX: sin parámetros
    @StateObject private var exerciseStore = ExerciseStore()

    @State private var name: String = ""
    @State private var note: String = ""
    @State private var daysPerWeek: Int = 3
    @State private var estimatedMinutes: Int = 45

    @State private var selectedExercises: [Exercise] = []
    @State private var showPicker = false
    @State private var isSaving = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: "Nueva rutina",
                    subtitle: "Crea un plan reusable y compártelo",
                    icon: "wand.and.stars",
                    accent: accent
                )

                FormCard(title: "Detalles", accent: accent) {
                    LabeledTextField(title: "Nombre", placeholder: "Ej: Torso/Pierna", text: $name)
                    LabeledTextField(title: "Notas", placeholder: "Objetivo, técnica, etc.", text: $note)

                    StepRow(title: "Días/semana", value: "\(daysPerWeek)", accent: accent) {
                        Stepper("", value: $daysPerWeek, in: 1...7).labelsHidden()
                    }
                    StepRow(title: "Duración", value: "\(estimatedMinutes) min", accent: accent) {
                        Stepper("", value: $estimatedMinutes, in: 10...180, step: 5).labelsHidden()
                    }
                }

                FormCard(title: "Ejercicios", accent: accent) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Seleccionados: \(selectedExercises.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                showPicker = true
                            } label: {
                                Label("Añadir", systemImage: "plus.circle.fill")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(accent)
                        }

                        if selectedExercises.isEmpty {
                            Text("Añade ejercicios desde la biblioteca para guardarlos en la rutina.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.gray.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        } else {
                            ForEach(Array(selectedExercises.enumerated()), id: \.element.id) { idx, ex in
                                HStack(spacing: 10) {
                                    Text("\(idx + 1). \(ex.nombre)")
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(1)

                                    Spacer()

                                    Button {
                                        selectedExercises.removeAll { $0.id == ex.id }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(12)
                                .background(Color.gray.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(TrainingBrand.separator, lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                Button {
                    Task { await saveRoutine() }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(isSaving ? "Guardando…" : "Guardar rutina")
                            .font(.headline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isSaving || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedExercises.isEmpty)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Crear rutina")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .sheet(isPresented: $showPicker) {
            ExercisePickerView(mode: .pick { ex in
                if !selectedExercises.contains(where: { $0.id == ex.id }) {
                    selectedExercises.append(ex)
                }
            })
            .environmentObject(exerciseStore)
        }
        .task {
            // ✅ En vez de bootstrap(), precargamos algo si quieres
            await exerciseStore.load(type: .fuerza)
        }
    }

    // MARK: - Save Supabase (rutinas + rutina_items)

    private func saveRoutine() async {
        isSaving = true
        defer { isSaving = false }

        do {
            let client = SupabaseManager.shared.client
            let service = TrainingSupabaseService(client: client)
            let autorId = try service.currentUserId()

            let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

            let routineDTO = TrainingSupabaseService.CreateRoutineDTO(
                autor_id: autorId.uuidString,
                titulo: cleanName,
                descripcion: cleanNote.isEmpty ? nil : cleanNote,
                tags: ["\(daysPerWeek)d/sem"],
                duracion_minutos: estimatedMinutes
            )

            let created = try await service.createRoutine(routineDTO)

            for (idx, ex) in selectedExercises.enumerated() {

                // ✅ Como ahora todo es "ejercicios", guardamos en ejercicio_id
                let itemDTO = TrainingSupabaseService.CreateRoutineItemDTO(
                    rutina_id: created.id.uuidString,
                    orden: idx,
                    ejercicio_id: ex.id.uuidString,
                    ejercicio_usuario_id: nil,
                    nombre_override: nil,
                    notas: nil,
                    sets_objetivo: 3,
                    rep_range_objetivo: nil,
                    descanso_segundos: 90
                )

                _ = try await service.createRoutineItem(itemDTO)
            }

            dismiss()
        } catch {
            // si quieres, muestra error
            // print("saveRoutine error:", error)
        }
    }
}

// MARK: - UI helpers

private struct FormCard<Content: View>: View {
    let title: String
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline.bold())
                Spacer()
                Circle()
                    .fill(accent.opacity(0.25))
                    .frame(width: 10, height: 10)
            }

            content
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }
}

private struct LabeledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

private struct StepRow<Control: View>: View {
    let title: String
    let value: String
    let accent: Color
    @ViewBuilder let control: Control

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(value).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            control
                .tint(accent)
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

import SwiftUI

struct CreateCustomExerciseView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = ExerciseStore() // o pásalo por environmentObject si prefieres

    private let accent = TrainingBrand.action

    @State private var nombre: String = ""
    @State private var tipo: ExerciseType = .fuerza
    @State private var musculoPrincipal: String = ""
    @State private var equipoText: String = ""          // "barra, banco"
    @State private var patron: String = ""              // "push/pull/squat..."
    @State private var tipoMedicion: ExerciseMetricType = .peso_reps
    @State private var descripcion: String = ""
    @State private var aliasesText: String = ""         // "bench press, banca"

    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    header

                    card(title: "Básico") {
                        field(title: "Nombre", placeholder: "Ej: Press banca con pausa", text: $nombre)

                        PickerRow(title: "Tipo") {
                            Picker("", selection: $tipo) {
                                ForEach(ExerciseType.allCases) { t in
                                    Text(t.title).tag(t)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        field(title: "Músculo principal", placeholder: "Ej: pecho", text: $musculoPrincipal)

                        PickerRow(title: "Tipo de medición") {
                            Picker("", selection: $tipoMedicion) {
                                Text("Peso + Reps").tag(ExerciseMetricType.peso_reps)
                                Text("Reps").tag(ExerciseMetricType.reps)
                                Text("Tiempo").tag(ExerciseMetricType.tiempo)
                                Text("Distancia").tag(ExerciseMetricType.distancia)
                                Text("Calorías").tag(ExerciseMetricType.calorias)
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    card(title: "Detalles") {
                        field(title: "Equipo (coma)", placeholder: "barra, banco", text: $equipoText)
                        field(title: "Patrón", placeholder: "push / pull / squat / hinge…", text: $patron)
                        field(title: "Aliases (coma)", placeholder: "bench press, banca", text: $aliasesText)
                        field(title: "Descripción", placeholder: "Notas rápidas…", text: $descripcion, axis: .vertical)
                    }

                    if let error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }

                    Button {
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
                    .disabled(isSaving || nombreTrimmed.isEmpty)

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
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nuevo ejercicio")
                .font(.title3.bold())
            Text("Se guardará como personal (solo tú) y se sincroniza con Supabase.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private func save() async {
        error = nil
        isSaving = true
        defer { isSaving = false }

        guard let autorId = AuthService.shared.sessionUserId else {
            error = "No hay sesión activa."
            return
        }

        // ✅ DTO Encodable (en vez de [String: Any])
        let dto = TrainingExercisesSupabaseService.CreateExerciseDTO(
            tipo: tipo.rawValue,
            nombre: nombreTrimmed,
            aliases: splitCSV(aliasesText),
            descripcion: descripcionTrimmed.isEmpty ? nil : descripcionTrimmed,
            musculo_principal: musculoPrincipalTrimmed.isEmpty ? nil : musculoPrincipalTrimmed,
            musculos_secundarios: [],
            equipo: splitCSV(equipoText),
            patron: patronTrimmed.isEmpty ? nil : patronTrimmed,
            tipo_medicion: tipoMedicion.rawValue,
            video_url: nil,
            es_publico: false,
            autor_id: autorId.uuidString
        )

        do {
            try await TrainingExercisesSupabaseService.shared.createCustomExercise(dto)

            // recargar la lista del tipo para ver el ejercicio al volver
            await store.load(type: tipo)

            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }

    private var nombreTrimmed: String { nombre.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var musculoPrincipalTrimmed: String { musculoPrincipal.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var patronTrimmed: String { patron.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var descripcionTrimmed: String { descripcion.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func splitCSV(_ text: String) -> [String] {
        text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    // MARK: - UI helpers

    private func card(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline.bold())
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
                .lineLimit(axis == .vertical ? 2...6 : 1...1)
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

import SwiftUI

struct IniciarEntrenamientoView: View {

    let plan: TrainingPlan?

    init(plan: TrainingPlan? = nil) {
        self.plan = plan
    }

    enum Mode: String, CaseIterable, Identifiable {
        case gimnasio = "Gimnasio"
        case cardio = "Cardio"
        case movilidad = "Movilidad"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .gimnasio

    // Supabase stores
    @StateObject private var exerciseStore = ExerciseStore(client: SupabaseManager.shared.client)
    @StateObject private var sessionStore = SessionStore(client: SupabaseManager.shared.client)

    // UI state
    @State private var showPicker = false
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var durationMinutes: Int = 45
    @State private var isSaving = false

    // Workout draft (por ID)
    struct ExerciseLine: Identifiable, Hashable {
        let id: UUID
        let exercise: Exercise
        var reps: Int?
        var weightKg: Double?
    }

    @State private var lines: [ExerciseLine] = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {

                if let plan {
                    SportHeroCard(
                        title: "Plan de hoy",
                        subtitle: plan.kind == .rutina ? (plan.routineTitle ?? "Rutina") : plan.kind.title,
                        icon: "checkmark.seal.fill",
                        accent: accentForPlan(plan)
                    )
                }

                headerCard

                // Lista ejercicios
                VStack(spacing: 12) {
                    HStack {
                        Text("Ejercicios")
                            .font(.headline.bold())
                        Spacer()
                        Button {
                            showPicker = true
                        } label: {
                            Label("Añadir", systemImage: "plus")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(TrainingBrand.action)
                    }

                    if lines.isEmpty {
                        Text("Añade ejercicios desde la biblioteca.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(TrainingBrand.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
                            )
                    } else {
                        ForEach(lines) { line in
                            ExerciseLineCard(
                                line: binding(for: line),
                                onDelete: { remove(line.id) }
                            )
                        }
                    }
                }
                .padding(14)
                .background(TrainingBrand.card)
                .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                        .strokeBorder(TrainingBrand.separator, lineWidth: 1)
                )

                Button {
                    Task { await saveSession() }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(isSaving ? "Guardando…" : "Finalizar y guardar")
                            .font(.headline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(TrainingBrand.action)
                    .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isSaving || lines.isEmpty)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Entrenar")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .sheet(isPresented: $showPicker) {
            ExercisePickerView(mode: .pick { ex in
                add(ex)
            })
            .environmentObject(exerciseStore)
        }
        .task {
            await exerciseStore.bootstrap()
            await sessionStore.bootstrap()

            if let plan { mode = map(plan.kind) }
            title = plan?.routineTitle ?? ""
        }
    }

    // MARK: - UI bits

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Título (opcional)", text: $title)
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duración")
                        .font(.subheadline.weight(.semibold))
                    Text("\(durationMinutes) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Stepper("", value: $durationMinutes, in: 10...240, step: 5)
                    .labelsHidden()
                    .tint(TrainingBrand.action)
            }
            .padding(12)
            .background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            TextField("Notas (opcional)", text: $notes, axis: .vertical)
                .lineLimit(2...5)
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    // MARK: - Draft management

    private func add(_ ex: Exercise) {
        // evita duplicados
        guard !lines.contains(where: { $0.exercise.id == ex.id }) else { return }
        lines.append(.init(id: UUID(), exercise: ex, reps: 8, weightKg: 0))
    }

    private func remove(_ lineId: UUID) {
        lines.removeAll { $0.id == lineId }
    }

    private func binding(for line: ExerciseLine) -> Binding<ExerciseLine> {
        guard let idx = lines.firstIndex(of: line) else {
            return .constant(line)
        }
        return $lines[idx]
    }

    // MARK: - Save to Supabase

    private func saveSession() async {
        isSaving = true
        defer { isSaving = false }

        do {
            let kind: TrainingPlanKind = {
                switch mode {
                case .gimnasio: return .gimnasio
                case .cardio: return .cardio
                case .movilidad: return .movilidad
                }
            }()

            let draft = SessionDraft(
                tipo: kind,
                planId: nil, // si más adelante guardas plan.id, puedes pasarlo aquí
                title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : title,
                durationMinutes: durationMinutes,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
            )

            let exercises: [SessionExerciseDraft] = lines.enumerated().map { idx, line in
                SessionExerciseDraft(
                    order: idx,
                    exerciseId: line.exercise.isCustom ? nil : line.exercise.id,
                    userExerciseId: line.exercise.isCustom ? line.exercise.id : nil,
                    nameSnapshot: line.exercise.name,
                    notes: nil
                )
            }

            var setsByOrder: [Int: [SessionSetDraft]] = [:]
            for (idx, line) in lines.enumerated() {
                let set = SessionSetDraft(
                    order: 0,
                    reps: line.reps,
                    weightKg: line.weightKg,
                    rpe: nil,
                    timeSec: nil,
                    distanceM: nil
                )
                setsByOrder[idx] = [set]
            }

            try await sessionStore.saveSession(
                draft: draft,
                exercises: exercises,
                setsByExerciseOrder: setsByOrder
            )
        } catch {
            // aquí puedes mostrar alert
            // print("saveSession error:", error)
        }
    }

    // MARK: - Helpers

    private func map(_ kind: TrainingPlanKind) -> Mode {
        switch kind {
        case .gimnasio, .rutina: return .gimnasio
        case .cardio: return .cardio
        case .movilidad: return .movilidad
        }
    }

    private func accentForPlan(_ plan: TrainingPlan) -> Color {
        switch plan.kind {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        case .rutina: return TrainingBrand.custom
        }
    }
}

private struct ExerciseLineCard: View {
    @Binding var line: IniciarEntrenamientoView.ExerciseLine
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(line.exercise.name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                Field(title: "Reps", value: Binding(
                    get: { line.reps ?? 0 },
                    set: { line.reps = $0 }
                ))

                FieldDouble(title: "Kg", value: Binding(
                    get: { line.weightKg ?? 0 },
                    set: { line.weightKg = $0 }
                ))
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private struct Field: View {
        let title: String
        @Binding var value: Int
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Stepper("\(value)", value: $value, in: 0...200)
                    .labelsHidden()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private struct FieldDouble: View {
        let title: String
        @Binding var value: Double
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Button("-") { value = max(0, value - 2.5) }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", value))
                        .font(.subheadline.weight(.semibold))
                        .frame(minWidth: 52, alignment: .leading)
                    Button("+") { value += 2.5 }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

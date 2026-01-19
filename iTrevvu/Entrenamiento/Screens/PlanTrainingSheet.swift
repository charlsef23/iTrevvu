import SwiftUI

struct PlanTrainingSheet: View {

    let date: Date
    let existing: TrainingPlan?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var planner: TrainingPlannerStore

    @State private var kind: TrainingPlanKind = .gimnasio
    @State private var routineTitle: String = ""
    @State private var duration: Int = 45
    @State private var note: String = ""

    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    headerCard

                    VStack(spacing: 12) {
                        kindPickerCard

                        if kind == .rutina {
                            routineCard
                        }

                        detailsCard
                        noteCard
                    }

                    if existing != nil {
                        Button(role: .destructive) {
                            Task { await deletePlan() }
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Eliminar planificación")
                                    .font(.headline.weight(.semibold))
                                Spacer()
                            }
                            .padding(14)
                        }
                        .buttonStyle(.plain)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
                    }

                    Spacer(minLength: 18)
                }
                .padding(16)
            }
            .background(TrainingBrand.bg)
            .navigationTitle(existing == nil ? "Planificar" : "Editar plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Guardando…" : "Guardar") {
                        Task { await savePlan() }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear { hydrate() }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Día seleccionado")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack {
                Text(formattedDate(date))
                    .font(.title3.bold())

                Spacer()

                Circle()
                    .fill(accentForKind(kind).opacity(0.25))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private var kindPickerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tipo")
                .font(.headline.bold())

            HStack(spacing: 10) {
                KindChip(title: "Gimnasio", isOn: kind == .gimnasio, accent: TrainingBrand.action) {
                    kind = .gimnasio
                }
                KindChip(title: "Cardio", isOn: kind == .cardio, accent: TrainingBrand.cardio) {
                    kind = .cardio
                }
                KindChip(title: "Movilidad", isOn: kind == .movilidad, accent: TrainingBrand.mobility) {
                    kind = .movilidad
                }
                KindChip(title: "Rutina", isOn: kind == .rutina, accent: TrainingBrand.custom) {
                    kind = .rutina
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
    }

    private var routineCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rutina")
                .font(.headline.bold())

            TextField("Ej: Torso/Pierna", text: $routineTitle)
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

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detalles")
                .font(.headline.bold())

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duración")
                        .font(.subheadline.weight(.semibold))
                    Text("\(duration) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Stepper("", value: $duration, in: 10...240, step: 5)
                    .labelsHidden()
                    .tint(accentForKind(kind))
            }
            .padding(12)
            .background(Color.gray.opacity(0.06))
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

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notas")
                .font(.headline.bold())

            TextField("Ej: trabajar técnica / intervalos / PR…", text: $note, axis: .vertical)
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

    // MARK: - Actions

    private func hydrate() {
        if let existing {
            kind = existing.kind
            routineTitle = existing.routineTitle ?? ""
            duration = existing.durationMinutes ?? 45
            note = existing.note ?? ""
        } else {
            kind = .gimnasio
            routineTitle = ""
            duration = 45
            note = ""
        }
    }

    private func savePlan() async {
        isSaving = true
        defer { isSaving = false }

        let plan = TrainingPlan(
            id: existing?.id ?? UUID(),
            date: date,
            kind: kind,
            routineTitle: kind == .rutina ? (routineTitle.isEmpty ? "Rutina" : routineTitle) : nil,
            durationMinutes: duration,
            note: note.isEmpty ? nil : note
        )

        await planner.upsert(plan)
        dismiss()
    }

    private func deletePlan() async {
        await planner.remove(for: date)
        dismiss()
    }

    // MARK: - Helpers

    private func accentForKind(_ k: TrainingPlanKind) -> Color {
        switch k {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        case .rutina: return TrainingBrand.custom
        }
    }

    private func formattedDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateStyle = .full
        return f.string(from: d).capitalized
    }
}

private struct KindChip: View {
    let title: String
    let isOn: Bool
    let accent: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isOn ? .white : .primary)
                .padding(.vertical, 9)
                .padding(.horizontal, 12)
                .background(
                    Capsule().fill(isOn ? accent : Color.gray.opacity(0.10))
                )
        }
        .buttonStyle(.plain)
    }
}

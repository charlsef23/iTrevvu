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

    // ✅ PlanMeta (más completo)
    @State private var goal: String = "Hipertrofia"
    @State private var rpe: Int = 7

    @State private var hasTime: Bool = false
    @State private var time: Date = .now

    @State private var checklistWarmup: Bool = true
    @State private var checklistCooldown: Bool = false
    @State private var checklistStretch: Bool = true
    @State private var checklistCreatine: Bool = false

    @State private var isSaving = false

    private let goals = ["Hipertrofia", "Fuerza", "Resistencia", "Técnica", "Recuperación"]

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
                        planningExtrasCard
                        checklistCard
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

    // MARK: - Cards

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
                KindChip(title: "Gimnasio", isOn: kind == .gimnasio, accent: TrainingBrand.action) { kind = .gimnasio }
                KindChip(title: "Cardio", isOn: kind == .cardio, accent: TrainingBrand.cardio) { kind = .cardio }
                KindChip(title: "Movilidad", isOn: kind == .movilidad, accent: TrainingBrand.mobility) { kind = .movilidad }
                KindChip(title: "Rutina", isOn: kind == .rutina, accent: TrainingBrand.custom) { kind = .rutina }
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

            Text("Tip: luego podrás vincular una rutina por ID cuando tengas Rutinas en Supabase.")
                .font(.caption)
                .foregroundStyle(.secondary)
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
            Text("Duración")
                .font(.headline.bold())

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Estimación")
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

    private var planningExtrasCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Planificación")
                .font(.headline.bold())

            // Objetivo
            VStack(alignment: .leading, spacing: 6) {
                Text("Objetivo")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Picker("Objetivo", selection: $goal) {
                    ForEach(goals, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
            }

            // Intensidad (RPE)
            VStack(alignment: .leading, spacing: 6) {
                Text("Intensidad (RPE)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack {
                    Text("\(rpe)")
                        .font(.headline.weight(.semibold))
                        .frame(width: 34, alignment: .leading)

                    Slider(
                        value: Binding(
                            get: { Double(rpe) },
                            set: { rpe = Int($0.rounded()) }
                        ),
                        in: 1...10,
                        step: 1
                    )
                    .tint(accentForKind(kind))
                }
            }

            // Hora
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Hora planificada", isOn: $hasTime)
                    .tint(accentForKind(kind))

                if hasTime {
                    DatePicker(
                        "Hora",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
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

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Checklist")
                .font(.headline.bold())

            Toggle("Warm-up", isOn: $checklistWarmup).tint(accentForKind(kind))
            Toggle("Cooldown suave", isOn: $checklistCooldown).tint(accentForKind(kind))
            Toggle("Estirar", isOn: $checklistStretch).tint(accentForKind(kind))
            Toggle("Creatina", isOn: $checklistCreatine).tint(accentForKind(kind))
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

            TextField("Ej: técnica, intervalos, PR…", text: $note, axis: .vertical)
                .lineLimit(2...6)
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

            // meta
            goal = existing.meta?.goal ?? "Hipertrofia"
            rpe = existing.meta?.rpe ?? 7

            if let t = existing.meta?.scheduledTime, let parsed = parseTimeHHmm(t) {
                hasTime = true
                time = parsed
            } else {
                hasTime = false
                time = .now
            }

            let ck = existing.meta?.checklist ?? [:]
            checklistWarmup = ck["Warm-up"] ?? true
            checklistCooldown = ck["Cooldown suave"] ?? false
            checklistStretch = ck["Estirar"] ?? true
            checklistCreatine = ck["Creatina"] ?? false
        } else {
            kind = .gimnasio
            routineTitle = ""
            duration = 45
            note = ""

            goal = "Hipertrofia"
            rpe = 7
            hasTime = false
            time = .now

            checklistWarmup = true
            checklistCooldown = false
            checklistStretch = true
            checklistCreatine = false
        }
    }

    private func savePlan() async {
        isSaving = true
        defer { isSaving = false }

        let trimmedRoutine = routineTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let routine = (kind == .rutina) ? (trimmedRoutine.isEmpty ? "Rutina" : trimmedRoutine) : nil

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote = trimmedNote.isEmpty ? nil : trimmedNote

        let meta = PlanMeta(
            goal: goal,
            rpe: rpe,
            scheduledTime: hasTime ? timeHHmm(time) : nil,
            checklist: [
                "Warm-up": checklistWarmup,
                "Cooldown suave": checklistCooldown,
                "Estirar": checklistStretch,
                "Creatina": checklistCreatine
            ]
        )

        let plan = TrainingPlan(
            id: existing?.id ?? UUID(),
            date: date,
            kind: kind,
            routineTitle: routine,
            durationMinutes: duration,
            note: finalNote,
            meta: meta
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

    private func timeHHmm(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "HH:mm"
        return f.string(from: d)
    }

    private func parseTimeHHmm(_ s: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "HH:mm"
        guard let dateOnlyTime = f.date(from: s) else { return nil }

        // pegamos la hora al día de "date"
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: dateOnlyTime)
        return cal.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: date)
    }
}

// MARK: - Chip

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

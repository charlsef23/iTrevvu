import SwiftUI

struct PlanTrainingSheet: View {

    let date: Date
    let existing: PlannedSession?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var planner: TrainingPlannerStore

    @State private var kind: TrainingSessionType = .gimnasio
    @State private var title: String = ""
    @State private var duration: Int = 45
    @State private var note: String = ""

    // Meta UI
    @State private var goal: PlanGoal? = nil
    @State private var rpeTarget: Double = 7.0
    @State private var useRPE: Bool = false

    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    summaryCard

                    sectionCard(title: "Tipo", icon: "square.grid.2x2.fill", tint: accentForKind(kind)) {
                        kindGrid
                    }

                    sectionCard(title: "Nombre", icon: "textformat", tint: accentForKind(kind)) {
                        nameEditor
                    }

                    sectionCard(title: "Detalles", icon: "clock.fill", tint: accentForKind(kind)) {
                        durationEditor
                    }

                    sectionCard(title: "Objetivo", icon: "target", tint: TrainingBrand.stats) {
                        goalEditor
                    }

                    sectionCard(title: "Notas", icon: "note.text", tint: .secondary) {
                        notesEditor
                    }

                    if existing?.id != nil {
                        deleteCard
                    }

                    Spacer(minLength: 16)
                }
                .padding(16)
            }
            .background(TrainingBrand.bg)
            .navigationTitle(existing == nil ? "Planificar" : "Editar sesión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Guardando…" : "Guardar") {
                        Task { await saveSession() }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .onAppear { hydrate() }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Día seleccionado")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(formattedDate(date))
                        .font(.title3.bold())
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(TrainingBrand.softFill(accentForKind(kind)))
                    Image(systemName: iconForKind(kind))
                        .font(.headline.bold())
                        .foregroundStyle(accentForKind(kind))
                }
                .frame(width: 44, height: 44)
            }

            Divider().opacity(0.6)

            HStack(spacing: 8) {
                Pill(text: titleForKind(kind), tint: accentForKind(kind))
                Pill(text: titleTrimmed.isEmpty ? "Sesión" : titleTrimmed, tint: .secondary)
                Pill(text: "\(duration) min", tint: .secondary)
                if let goal { Pill(text: goal.title, tint: TrainingBrand.stats) }
                if useRPE { Pill(text: "RPE \(String(format: "%.1f", rpeTarget))", tint: TrainingBrand.stats) }
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    // MARK: - Sections

    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(TrainingBrand.softFill(tint))
                    Image(systemName: icon)
                        .font(.subheadline.bold())
                        .foregroundStyle(tint)
                }
                .frame(width: 32, height: 32)

                Text(title).font(.headline.bold())
                Spacer()
            }

            content()
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private var deleteCard: some View {
        Button(role: .destructive) { Task { await deleteSession() } } label: {
            HStack {
                Image(systemName: "trash.fill")
                Text("Eliminar sesión").font(.headline.weight(.semibold))
                Spacer()
            }
            .padding(14)
        }
        .buttonStyle(.plain)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner))
    }

    // MARK: - Editors

    private var kindGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                KindTile("Gimnasio", "Fuerza", "dumbbell.fill", TrainingBrand.action, kind == .gimnasio) { kind = .gimnasio }
                KindTile("Cardio", "Tiempo", "figure.run", TrainingBrand.cardio, kind == .cardio) { kind = .cardio }
            }

            HStack(spacing: 10) {
                KindTile("Movilidad", "Recuperación", "figure.cooldown", TrainingBrand.mobility, kind == .movilidad) { kind = .movilidad }
                KindTile("HIIT", "Intervalos", "bolt.fill", TrainingBrand.cardio, kind == .hiit) { kind = .hiit }
            }

            HStack(spacing: 10) {
                KindTile("Calistenia", "Peso corporal", "figure.strengthtraining.traditional", TrainingBrand.action, kind == .calistenia) { kind = .calistenia }
                KindTile("Deporte", "Partido", "sportscourt.fill", TrainingBrand.custom, kind == .deporte) { kind = .deporte }
            }

            HStack(spacing: 10) {
                KindTile("Rehab", "Lesión", "cross.case.fill", TrainingBrand.mobility, kind == .rehab) { kind = .rehab }
                KindTile("Descanso", "Off", "bed.double.fill", .secondary, kind == .descanso) { kind = .descanso }
            }

            // Rutina (plantilla)
            KindTile("Rutina", "Plantilla", "list.bullet.rectangle", TrainingBrand.custom, kind == .rutina) { kind = .rutina }
        }
    }

    private var nameEditor: some View {
        TextField("Nombre de la sesión", text: $title)
            .padding(12)
            .background(Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var durationEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Stepper("Duración: \(duration) min", value: $duration, in: 5...600, step: 5)
                .padding(12)
                .background(Color.gray.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Toggle(isOn: $useRPE) {
                Text("Objetivo de esfuerzo (RPE)")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(TrainingBrand.stats)

            if useRPE {
                VStack(alignment: .leading, spacing: 8) {
                    Text("RPE: \(String(format: "%.1f", rpeTarget))")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Slider(value: $rpeTarget, in: 5...10, step: 0.5)
                }
                .padding(12)
                .background(Color.gray.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var goalEditor: some View {
        FlowWrap {
            ForEach(PlanGoal.allCases) { g in
                SelectChip(g.title, g.systemImage, goal == g) {
                    goal = (goal == g) ? nil : g
                }
            }
        }
    }

    private var notesEditor: some View {
        TextField("Notas", text: $note, axis: .vertical)
            .lineLimit(3...6)
            .padding(12)
            .background(Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Actions

    private func hydrate() {
        guard let existing else { return }

        kind = existing.tipo
        title = existing.nombre
        duration = existing.duracionMinutos ?? 45
        note = existing.notas ?? ""

        // meta
        if let meta = existing.meta {
            if let g = meta.goal {
                // si tu PlanGoal tiene mapping por title, intenta igualarlo
                goal = PlanGoal.allCases.first(where: { $0.title == g })
            }
            if let rpe = meta.rpeTarget {
                useRPE = true
                rpeTarget = rpe
            }
        }
    }

    private func saveSession() async {
        if titleTrimmed.isEmpty { return }
        isSaving = true
        defer { isSaving = false }

        let mergedTags = existing?.meta?.tags

        let meta = SessionMeta(
            goal: goal?.title,
            rpeTarget: useRPE ? rpeTarget : nil,
            tags: mergedTags
        )

        let session = PlannedSession(
            id: existing?.id ?? nil, // nil => insert
            autorId: existing?.autorId,
            date: date,
            hora: existing?.hora ?? "09:00:00",
            tipo: kind,
            nombre: titleTrimmed,
            icono: iconForKind(kind),
            color: colorTokenForKind(kind),
            duracionMinutos: duration,
            objetivo: nil,
            notas: noteTrimmed.isEmpty ? nil : noteTrimmed,
            meta: meta,
            createdAt: existing?.createdAt,
            updatedAt: existing?.updatedAt
        )

        await planner.upsertSession(session)
        dismiss()
    }

    private func deleteSession() async {
        guard let id = existing?.id else { return }
        await planner.deleteSession(sessionId: id)
        dismiss()
    }

    // MARK: - Helpers

    private var titleTrimmed: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var noteTrimmed: String { note.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func formattedDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateStyle = .full
        return f.string(from: d).capitalized
    }

    // MARK: - Switches (EXHAUSTIVOS)

    private func titleForKind(_ k: TrainingSessionType) -> String {
        switch k {
        case .gimnasio: return "Gimnasio"
        case .cardio: return "Cardio"
        case .movilidad: return "Movilidad"
        case .rutina: return "Rutina"
        case .hiit: return "HIIT"
        case .calistenia: return "Calistenia"
        case .deporte: return "Deporte"
        case .rehab: return "Rehab"
        case .descanso: return "Descanso"
        }
    }

    private func iconForKind(_ k: TrainingSessionType) -> String {
        switch k {
        case .gimnasio: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        case .rutina: return "list.bullet.rectangle"
        case .hiit: return "bolt.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .deporte: return "sportscourt.fill"
        case .rehab: return "cross.case.fill"
        case .descanso: return "bed.double.fill"
        }
    }

    private func accentForKind(_ k: TrainingSessionType) -> Color {
        switch k {
        case .gimnasio, .calistenia: return TrainingBrand.action
        case .cardio, .hiit: return TrainingBrand.cardio
        case .movilidad, .rehab, .descanso: return TrainingBrand.mobility
        case .rutina, .deporte: return TrainingBrand.custom
        }
    }

    private func colorTokenForKind(_ k: TrainingSessionType) -> String {
        switch k {
        case .gimnasio, .calistenia: return "action"
        case .cardio, .hiit: return "cardio"
        case .movilidad, .rehab, .descanso: return "mobility"
        case .rutina, .deporte: return "custom"
        }
    }
}

// MARK: - Small UI components (mismos que ya usabas)

private struct KindTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let isOn: Bool
    let action: () -> Void

    init(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color, _ isOn: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.isOn = isOn
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                VStack(alignment: .leading) {
                    Text(title).bold()
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if isOn {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(tint)
                }
            }
            .padding(12)
            .background(isOn ? tint.opacity(0.12) : Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

private struct Pill: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .foregroundStyle(tint == .secondary ? .primary : tint)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Capsule().fill(tint.opacity(0.15)))
    }
}

private struct SelectChip: View {
    let title: String
    let icon: String
    let isOn: Bool
    let action: () -> Void

    init(_ title: String, _ icon: String, _ isOn: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isOn = isOn
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isOn ? TrainingBrand.stats : Color.gray.opacity(0.15))
            .foregroundStyle(isOn ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct FlowWrap<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
            content
        }
    }
}

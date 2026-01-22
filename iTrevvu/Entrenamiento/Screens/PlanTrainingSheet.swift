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

    // Meta
    @State private var goal: PlanGoal? = nil
    @State private var rpeTarget: Double = 7.0
    @State private var useRPE: Bool = false

    // UX
    @State private var isSaving = false
    @State private var showValidation = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    summaryCard

                    sectionCard(title: "Tipo", icon: "square.grid.2x2.fill", tint: accentForKind(kind)) {
                        kindGrid
                    }

                    if kind == .rutina {
                        sectionCard(title: "Rutina", icon: "list.bullet.rectangle.portrait", tint: TrainingBrand.custom) {
                            routineEditor
                        }
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

                    if existing != nil {
                        deleteCard
                    }

                    Spacer(minLength: 16)
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

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Día seleccionado")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(formattedDate(date))
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(accentForKind(kind)))
                    Image(systemName: iconForKind(kind))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accentForKind(kind))
                }
                .frame(width: 44, height: 44)
            }

            Divider().opacity(0.6)

            HStack(spacing: 10) {
                Pill(text: kind.title, tint: accentForKind(kind))

                if kind == .rutina {
                    Pill(text: routineTitle.isEmpty ? "Rutina" : routineTitle, tint: TrainingBrand.custom)
                }

                Pill(text: "\(duration) min", tint: .secondary)

                if let goal {
                    Pill(text: goal.title, tint: TrainingBrand.stats)
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
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }

    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(TrainingBrand.softFill(tint))
                    Image(systemName: icon)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(tint)
                }
                .frame(width: 32, height: 32)

                Text(title)
                    .font(.headline.bold())

                Spacer()
            }

            content()
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

    private var deleteCard: some View {
        Button(role: .destructive) {
            Task { await deletePlan() }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "trash.fill")
                Text("Eliminar planificación")
                    .font(.headline.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
        }
        .buttonStyle(.plain)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(Color.red.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Section Content

    private var kindGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                KindTile(title: "Gimnasio", subtitle: "Fuerza / sets", icon: "dumbbell.fill", tint: TrainingBrand.action, isOn: kind == .gimnasio) {
                    kind = .gimnasio
                }
                KindTile(title: "Cardio", subtitle: "Tiempo / distancia", icon: "figure.run", tint: TrainingBrand.cardio, isOn: kind == .cardio) {
                    kind = .cardio
                }
            }

            HStack(spacing: 10) {
                KindTile(title: "Movilidad", subtitle: "Recuperación", icon: "figure.cooldown", tint: TrainingBrand.mobility, isOn: kind == .movilidad) {
                    kind = .movilidad
                }
                KindTile(title: "Rutina", subtitle: "Plantilla guardada", icon: "list.bullet", tint: TrainingBrand.custom, isOn: kind == .rutina) {
                    kind = .rutina
                }
            }
        }
    }

    private var routineEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Nombre de la rutina")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Ej: Torso/Pierna", text: $routineTitle)
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(showValidation && routineTitleTrimmed.isEmpty ? Color.red.opacity(0.5) : TrainingBrand.separator, lineWidth: 1)
                )

            if showValidation && routineTitleTrimmed.isEmpty {
                Text("Pon un nombre para la rutina.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }
        }
    }

    private var durationEditor: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duración estimada")
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

            VStack(alignment: .leading, spacing: 6) {
                Slider(value: Binding(
                    get: { Double(duration) },
                    set: { duration = Int($0.rounded()) }
                ), in: 10...240, step: 5)

                HStack {
                    Text("10")
                    Spacer()
                    Text("240")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var goalEditor: some View {
        VStack(spacing: 12) {

            // Objetivo (chips)
            VStack(alignment: .leading, spacing: 10) {
                Text("Objetivo del día")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                FlowWrap(spacing: 8) {
                    ForEach(PlanGoal.allCases) { g in
                        SelectChip(
                            title: g.title,
                            icon: g.systemImage,
                            isOn: goal == g,
                            tint: TrainingBrand.stats
                        ) {
                            goal = (goal == g) ? nil : g
                        }
                    }
                }
            }

            Divider().opacity(0.55)

            // Intensidad
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: $useRPE) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Intensidad objetivo (RPE)")
                            .font(.subheadline.weight(.semibold))
                        Text("Opcional · útil para fuerza/hipertrofia")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(TrainingBrand.stats)

                if useRPE {
                    HStack {
                        Text("RPE")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(String(format: "%.1f", rpeTarget))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(TrainingBrand.stats)
                    }

                    Slider(value: $rpeTarget, in: 1...10, step: 0.5)
                }
            }
        }
    }

    private var notesEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notas")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Ej: técnica / intervalos / PR…", text: $note, axis: .vertical)
                .lineLimit(3...8)
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Actions

    private func hydrate() {
        if let existing {
            kind = existing.kind
            routineTitle = existing.routineTitle ?? ""
            duration = existing.durationMinutes ?? 45
            note = existing.note ?? ""

            goal = existing.meta?.goal
            if let rpe = existing.meta?.rpeTarget {
                useRPE = true
                rpeTarget = rpe
            } else {
                useRPE = false
                rpeTarget = 7.0
            }
        } else {
            kind = .gimnasio
            routineTitle = ""
            duration = 45
            note = ""

            goal = nil
            useRPE = false
            rpeTarget = 7.0
        }
    }

    private func savePlan() async {
        showValidation = true

        // ✅ validación mínima
        if kind == .rutina && routineTitleTrimmed.isEmpty {
            return
        }

        isSaving = true
        defer { isSaving = false }

        let meta = PlanMeta(
            goal: goal,
            rpeTarget: useRPE ? rpeTarget : nil
        )

        let plan = TrainingPlan(
            id: existing?.id ?? UUID(),
            date: date,
            kind: kind,
            routineTitle: kind == .rutina ? (routineTitleTrimmed.isEmpty ? "Rutina" : routineTitleTrimmed) : nil,
            durationMinutes: duration,
            note: noteTrimmed.isEmpty ? nil : noteTrimmed,
            meta: (meta.goal == nil && meta.rpeTarget == nil) ? nil : meta
        )

        await planner.upsert(plan)
        dismiss()
    }

    private func deletePlan() async {
        await planner.remove(for: date)
        dismiss()
    }

    // MARK: - Helpers

    private var routineTitleTrimmed: String {
        routineTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var noteTrimmed: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func iconForKind(_ k: TrainingPlanKind) -> String {
        switch k {
        case .gimnasio: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        case .rutina: return "list.bullet.rectangle"
        }
    }

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

// MARK: - Small UI building blocks (in-file)

private struct KindTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let isOn: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(tint))
                    Image(systemName: icon)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(tint)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? tint : .secondary)
            }
            .padding(12)
            .background(isOn ? tint.opacity(0.10) : Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isOn ? tint.opacity(0.25) : TrainingBrand.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct Pill: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint == .secondary ? .primary : tint)
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(
                Capsule().fill(tint == .secondary ? Color.gray.opacity(0.12) : tint.opacity(0.14))
            )
    }
}

private struct SelectChip: View {
    let title: String
    let icon: String
    let isOn: Bool
    let tint: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(isOn ? .white : .primary)
            .padding(.vertical, 9)
            .padding(.horizontal, 12)
            .background(
                Capsule().fill(isOn ? tint : Color.gray.opacity(0.10))
            )
        }
        .buttonStyle(.plain)
    }
}

/// Wrap simple para chips sin crear archivos extra
private struct FlowWrap<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        // Layout básico compatible: usa LazyVGrid para “wrap”
        // (2 columnas flexibles -> chips se adaptan bien)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: spacing)], spacing: spacing) {
            content
        }
    }
}

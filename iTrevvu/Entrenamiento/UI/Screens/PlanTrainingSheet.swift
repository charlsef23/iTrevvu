import SwiftUI

struct PlanTrainingSheet: View {

    let date: Date
    let existing: PlannedSession?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var planner: TrainingPlannerStore

    @State private var kind: TrainingSessionType = .gimnasio

    // ✅ Nombre arriba
    @State private var title: String = ""

    @State private var duration: Int = 45
    @State private var note: String = ""

    // ✅ Repetición
    @State private var repeatEnabled: Bool = false
    @State private var repeatWeekdays: Set<Int> = [1,2,3,4,5] // 1=Lunes ... 7=Domingo
    @State private var repeatEndEnabled: Bool = false
    @State private var repeatEndDate: Date = .now
    @State private var repeatTimeEnabled: Bool = true
    @State private var repeatTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now

    // UX
    @State private var isSaving = false
    @State private var showValidation = false
    @State private var showNamePicker = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    nameTopCard

                    if showValidation {
                        Text("Pon un nombre para la sesión.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    summaryCard

                    sectionCard(title: "Tipo", icon: "square.grid.2x2.fill", tint: accentForKind(kind)) {
                        kindGrid
                    }

                    sectionCard(title: "Detalles", icon: "clock.fill", tint: accentForKind(kind)) {
                        durationEditor
                    }

                    sectionCard(title: "Repetir", icon: "arrow.triangle.2.circlepath", tint: TrainingBrand.stats) {
                        repeatEditor
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
        .sheet(isPresented: $showNamePicker) {
            RecentNamesSheet(
                names: RecentPlanNamesStore.load(),
                onPick: { picked in
                    title = picked
                    showNamePicker = false
                },
                onClearAll: {
                    RecentPlanNamesStore.clear()
                }
            )
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Nombre top

    private var nameTopCard: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("Nombre")
                    .font(.headline.bold())

                Spacer()

                Button { showNamePicker = true } label: {
                    Label("Reutilizar", systemImage: "clock.arrow.circlepath")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(TrainingBrand.stats)
                .buttonStyle(.plain)
            }

            TextField("Ej: Pierna · Hipertrofia", text: $title)
                .textInputAutocapitalization(.sentences)
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

                if repeatEnabled {
                    Pill(text: "Repite", tint: TrainingBrand.stats)
                }
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

                Text(title)
                    .font(.headline.bold())

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
        Button(role: .destructive) {
            Task { await deleteSession() }
        } label: {
            HStack {
                Image(systemName: "trash.fill")
                Text("Eliminar sesión")
                    .font(.headline.weight(.semibold))
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
                KindTile("Rutina", "Plantilla", "list.bullet", TrainingBrand.custom, kind == .rutina) { kind = .rutina }
            }
        }
    }

    private var durationEditor: some View {
        Stepper("Duración: \(duration) min", value: $duration, in: 10...240, step: 5)
            .padding(12)
            .background(Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var repeatEditor: some View {
        VStack(alignment: .leading, spacing: 12) {

            Toggle("Repetir esta sesión", isOn: $repeatEnabled)
                .tint(TrainingBrand.stats)

            if repeatEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Días")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    WeekdayPicker(selected: $repeatWeekdays)
                }

                Toggle("Hora fija", isOn: $repeatTimeEnabled)
                    .tint(TrainingBrand.stats)

                if repeatTimeEnabled {
                    DatePicker("Hora", selection: $repeatTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                }

                Toggle("Fin", isOn: $repeatEndEnabled)
                    .tint(TrainingBrand.stats)

                if repeatEndEnabled {
                    DatePicker("Hasta", selection: $repeatEndDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Text("Se guardará como repetición y se generará automáticamente.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
    }

    private func saveSession() async {
        showValidation = false

        let name = titleTrimmed
        if name.isEmpty {
            showValidation = true
            return
        }

        isSaving = true
        defer { isSaving = false }

        // ✅ guarda nombre para reutilizar
        RecentPlanNamesStore.append(name)

        // 1) Guardar sesión del día (plan_sesiones)
        let session = PlannedSession(
            id: existing?.id ?? UUID(),
            date: date,
            hora: existing?.hora ?? "09:00:00",
            tipo: kind,
            nombre: name,
            icono: iconForKind(kind),
            color: colorTokenForKind(kind),
            duracionMinutos: duration,
            objetivo: nil,
            notas: noteTrimmed.isEmpty ? nil : noteTrimmed,
            meta: existing?.meta
        )

        // ✅ LLAMADA CORRECTA (sin autorId)
        await planner.upsertSession(session)

        // 2) Repetición
        if repeatEnabled {
            let hour = Calendar.current.component(.hour, from: repeatTime)
            let minute = Calendar.current.component(.minute, from: repeatTime)
            let horaString = repeatTimeEnabled
                ? String(format: "%02d:%02d:00", hour, minute)
                : nil

            let end = repeatEndEnabled ? repeatEndDate : nil

            // ✅ TIPO CORRECTO: TrainingRepeatTemplate (NO RepeatTemplate)
            let template = TrainingRepeatTemplate(
                tipo: kind.rawValue,
                nombre: name,
                icono: iconForKind(kind),
                color: colorTokenForKind(kind),
                duracion_minutos: duration,
                notas: noteTrimmed.isEmpty ? nil : noteTrimmed
            )

            await planner.upsertRepeatPlan(
                template: template,
                startDate: date,
                endDate: end,
                byweekday: Array(repeatWeekdays).sorted(),
                hora: horaString
            )
        }

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

    private func titleForKind(_ k: TrainingSessionType) -> String { k.title }

    private func iconForKind(_ k: TrainingSessionType) -> String {
        switch k {
        case .gimnasio: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        case .rutina: return "list.bullet"
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

// MARK: - Weekday Picker

private struct WeekdayPicker: View {
    @Binding var selected: Set<Int> // 1...7 (L..D)

    private let items: [(Int, String)] = [
        (1,"L"), (2,"M"), (3,"X"), (4,"J"), (5,"V"), (6,"S"), (7,"D")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.0) { (day, label) in
                Button {
                    if selected.contains(day) { selected.remove(day) }
                    else { selected.insert(day) }
                } label: {
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selected.contains(day) ? .white : .primary)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle().fill(selected.contains(day) ? TrainingBrand.stats : Color.gray.opacity(0.10))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Recent names sheet

private struct RecentNamesSheet: View {
    let names: [String]
    let onPick: (String) -> Void
    let onClearAll: () -> Void

    var body: some View {
        NavigationStack {
            List {
                if names.isEmpty {
                    Text("Aún no hay nombres guardados.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(names, id: \.self) { n in
                        Button { onPick(n) } label: { Text(n) }
                    }
                    Button(role: .destructive) { onClearAll() } label: { Text("Borrar historial") }
                }
            }
            .navigationTitle("Reutilizar nombre")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

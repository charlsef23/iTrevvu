import SwiftUI

struct PlanTrainingSheet: View {

    let date: Date
    let existing: TrainingPlan?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var planner: TrainingPlannerStore

    @State private var kind: TrainingPlanKind = .gimnasio
    @State private var routineTitle: String = ""
    @State private var durationMinutes: Int = 45
    @State private var note: String = ""

    @State private var showAllRoutines = false

    // Mock: cámbialo por tus rutinas reales cuando quieras
    private let routinesRecommended = [
        "Fuerza · Parte superior",
        "Hipertrofia · Pierna",
        "Full Body · Express"
    ]

    private let routinesAll = [
        "Fuerza · Parte superior",
        "Hipertrofia · Pierna",
        "Full Body · Express",
        "Torso / Pierna",
        "Push / Pull / Legs",
        "Cardio · Intervalos",
        "Cardio · Zona 2",
        "Movilidad · 10 min",
        "Movilidad · Cadera + Tobillo"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {

                        typePicker

                        if kind == .rutina {
                            routinePicker
                        }

                        durationPicker

                        notesCard

                        if existing != nil {
                            deleteCard
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }

                saveBar
            }
            .background(TrainingBrand.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                if let existing {
                    kind = existing.kind
                    routineTitle = existing.routineTitle ?? ""
                    durationMinutes = existing.durationMinutes ?? 45
                    note = existing.note ?? ""
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Planificar")
                        .font(.title3.bold())

                    Text(prettyDate(date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if existing != nil {
                    Text("Editando")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(TrainingBrand.stats)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(TrainingBrand.stats.opacity(0.10))
                        .clipShape(Capsule())
                }
            }

            Text("Elige el tipo, duración y (si quieres) una rutina. En Entrenamiento verás el plan del día y podrás iniciarlo.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - Type Picker

    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tipo")
                .font(.headline.bold())

            HStack(spacing: 10) {
                typeCard(.gimnasio, title: "Gimnasio", icon: "dumbbell.fill", tint: TrainingBrand.action)
                typeCard(.cardio, title: "Cardio", icon: "figure.run", tint: TrainingBrand.cardio)
                typeCard(.movilidad, title: "Movilidad", icon: "figure.cooldown", tint: TrainingBrand.mobility)
                typeCard(.rutina, title: "Rutina", icon: "list.bullet.rectangle.portrait", tint: TrainingBrand.custom)
            }
        }
    }

    private func typeCard(_ value: TrainingPlanKind, title: String, icon: String, tint: Color) -> some View {
        let selected = (kind == value)

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                kind = value
                if kind != .rutina { routineTitle = "" }
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(tint.opacity(selected ? 0.18 : 0.10))
                    Image(systemName: icon)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(tint)
                }
                .frame(width: 44, height: 44)

                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(TrainingBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.cornerSmall, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TrainingBrand.cornerSmall, style: .continuous)
                    .strokeBorder(selected ? tint.opacity(0.45) : TrainingBrand.separator, lineWidth: selected ? 1.2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Routine Picker

    private var routinePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Rutina")
                    .font(.headline.bold())
                Spacer()
                Button(showAllRoutines ? "Ver menos" : "Ver todas") {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showAllRoutines.toggle()
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }

            VStack(spacing: 10) {
                if routineTitle.isEmpty {
                    RoutineRow(title: "Selecciona una rutina", subtitle: "Obligatorio para tipo Rutina", isSelected: false, tint: TrainingBrand.custom)
                        .opacity(0.65)
                } else {
                    RoutineRow(title: routineTitle, subtitle: "Seleccionada", isSelected: true, tint: TrainingBrand.custom)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Recomendadas")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    ForEach(routinesRecommended, id: \.self) { r in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                routineTitle = r
                            }
                        } label: {
                            RoutineRow(title: r, subtitle: "Toque para seleccionar", isSelected: routineTitle == r, tint: TrainingBrand.custom)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if showAllRoutines {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Todas")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        ForEach(routinesAll, id: \.self) { r in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    routineTitle = r
                                }
                            } label: {
                                RoutineRow(title: r, subtitle: "Toque para seleccionar", isSelected: routineTitle == r, tint: TrainingBrand.custom)
                            }
                            .buttonStyle(.plain)
                        }
                    }
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

    // MARK: - Duration

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Duración")
                .font(.headline.bold())

            HStack(spacing: 10) {
                DurationChip(minutes: 30, selected: durationMinutes == 30) { durationMinutes = 30 }
                DurationChip(minutes: 45, selected: durationMinutes == 45) { durationMinutes = 45 }
                DurationChip(minutes: 60, selected: durationMinutes == 60) { durationMinutes = 60 }
                DurationChip(minutes: 90, selected: durationMinutes == 90) { durationMinutes = 90 }
            }

            HStack {
                Text("Personalizar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(durationMinutes) min")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { Double(durationMinutes) },
                    set: { durationMinutes = Int($0 / 5) * 5 }
                ),
                in: 10...180,
                step: 5
            )
            .tint(TrainingBrand.stats)
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    // MARK: - Notes

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notas")
                .font(.headline.bold())

            TextField("Opcional: objetivo, sensaciones, ejercicios clave…", text: $note, axis: .vertical)
                .lineLimit(3...6)
                .font(.subheadline)
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

    // MARK: - Delete

    private var deleteCard: some View {
        Button(role: .destructive) {
            planner.remove(for: date)
            dismiss()
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Eliminar planificación")
                Spacer()
            }
            .font(.subheadline.weight(.semibold))
            .padding(14)
            .background(TrainingBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                    .strokeBorder(Color.red.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save Bar (bottom)

    private var saveBar: some View {
        VStack(spacing: 10) {
            Divider().opacity(0.25)

            Button {
                save()
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text(existing == nil ? "Guardar planificación" : "Guardar cambios")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(accentFor(kind))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(kind == .rutina && routineTitle.isEmpty)
            .opacity((kind == .rutina && routineTitle.isEmpty) ? 0.55 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(TrainingBrand.bg)
    }

    // MARK: - Actions

    private func save() {
        let plan = TrainingPlan(
            id: existing?.id ?? UUID(),
            date: date,
            kind: kind,
            routineTitle: kind == .rutina ? routineTitle : nil,
            durationMinutes: durationMinutes,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note
        )
        planner.upsert(plan)
        dismiss()
    }

    // MARK: - Helpers

    private func accentFor(_ kind: TrainingPlanKind) -> Color {
        switch kind {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        case .rutina: return TrainingBrand.custom
        }
    }

    private func prettyDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "es_ES")
        fmt.dateFormat = "EEEE, d MMMM"
        return fmt.string(from: date).capitalized
    }
}

// MARK: - Small components

private struct RoutineRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(isSelected ? 0.18 : 0.10))
                Image(systemName: isSelected ? "checkmark" : "circle")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(tint.opacity(isSelected ? 1 : 0.55))
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(isSelected ? tint.opacity(0.35) : Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct DurationChip: View {
    let minutes: Int
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { onTap() }
        } label: {
            Text("\(minutes)′")
                .font(.caption.weight(.semibold))
                .foregroundStyle(selected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(selected ? TrainingBrand.stats : Color.gray.opacity(0.10))
                )
        }
        .buttonStyle(.plain)
    }
}

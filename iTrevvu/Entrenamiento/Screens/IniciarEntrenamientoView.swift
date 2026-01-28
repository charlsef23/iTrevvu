import SwiftUI

struct IniciarEntrenamientoView: View {

    let plan: PlannedSession?
    let presetExercises: [Exercise]

    init(plan: PlannedSession? = nil, presetExercises: [Exercise] = []) {
        self.plan = plan
        self.presetExercises = presetExercises
    }

    enum Mode: String, CaseIterable, Identifiable {
        case gimnasio = "Gimnasio"
        case cardio = "Cardio"
        case movilidad = "Movilidad"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .gimnasio
    @StateObject private var exerciseStore = ExerciseStore()

    // Builder local (fase 1)
    @State private var sessionItems: [SessionItemDraft] = []
    @State private var showPicker = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                header
                modePicker
                quickActions
                sessionBuilderCard

                Spacer(minLength: 90)
            }
            .padding(16)
        }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .background(TrainingBrand.bg)
        .navigationTitle("Entrenar")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .task { await exerciseStore.load(type: .fuerza) }
        .onAppear {
            if let plan { mode = map(plan.tipo) }
            // ✅ añade los ejercicios preseleccionados
            if !presetExercises.isEmpty && sessionItems.isEmpty {
                sessionItems = presetExercises.map {
                    SessionItemDraft(title: $0.nombre, subtitle: $0.tipo.title, icon: $0.tipo.icon)
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            ExercisePickerView(
                mode: .multiPick { picked in
                    // merge sin duplicados por id
                    let existingIds = Set(sessionItems.compactMap { $0.exerciseId })
                    let newOnes = picked
                        .filter { !existingIds.contains($0.id) }
                        .map { SessionItemDraft(exerciseId: $0.id, title: $0.nombre, subtitle: $0.tipo.title, icon: $0.tipo.icon) }
                    sessionItems.append(contentsOf: newOnes)
                }
            )
            .environmentObject(exerciseStore)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            if let plan {
                SportHeroCard(
                    title: "Plan de hoy",
                    subtitle: subtitleForPlan(plan),
                    icon: plan.icono ?? "checkmark.seal.fill",
                    accent: accentForPlan(plan)
                )
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(TrainingBrand.softFill(TrainingBrand.stats))
                            Image(systemName: "bolt.fill")
                                .font(.headline.bold())
                                .foregroundStyle(TrainingBrand.stats)
                        }
                        .frame(width: 46, height: 46)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Entrenamiento libre")
                                .font(.headline.bold())
                            Text("Elige modo y añade ejercicios.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
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
        }
    }

    // MARK: - Mode Picker

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Modo").font(.headline.bold())

            HStack(spacing: 10) {
                ModeTile("Gimnasio", "Fuerza / sets", "dumbbell.fill", mode == .gimnasio, TrainingBrand.action) {
                    mode = .gimnasio
                }
                ModeTile("Cardio", "Tiempo / ritmo", "figure.run", mode == .cardio, TrainingBrand.cardio) {
                    mode = .cardio
                }
                ModeTile("Movilidad", "Recuperación", "figure.cooldown", mode == .movilidad, TrainingBrand.mobility) {
                    mode = .movilidad
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

    // MARK: - Quick actions

    private var quickActions: some View {
        VStack(spacing: 10) {
            Button { showPicker = true } label: {
                ActionRow(
                    title: "Añadir ejercicios",
                    subtitle: "Selecciona varios para entrenar ahora",
                    icon: "plus.circle.fill",
                    accent: accentForMode(mode)
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                ExerciseLibraryHubView(onStartWithExercises: { picked in
                    // si vuelves aquí desde library, añade
                    let existingIds = Set(sessionItems.compactMap { $0.exerciseId })
                    let newOnes = picked
                        .filter { !existingIds.contains($0.id) }
                        .map { SessionItemDraft(exerciseId: $0.id, title: $0.nombre, subtitle: $0.tipo.title, icon: $0.tipo.icon) }
                    sessionItems.append(contentsOf: newOnes)
                })
                .environmentObject(exerciseStore)
            } label: {
                ActionRow(
                    title: "Biblioteca completa",
                    subtitle: "Por categorías",
                    icon: "square.grid.2x2.fill",
                    accent: TrainingBrand.stats
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Session builder

    private var sessionBuilderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sesión").font(.headline.bold())
                Spacer()
                Button {
                    showPicker = true
                } label: {
                    Label("Añadir", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(accentForMode(mode))
                .buttonStyle(.plain)
            }

            if sessionItems.isEmpty {
                EmptyStateBox(
                    title: "Aún no has añadido ejercicios",
                    subtitle: "Pulsa “Añadir” y selecciona varios."
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(sessionItems) { item in
                        SessionItemRow(
                            title: item.title,
                            subtitle: item.subtitle,
                            icon: item.icon,
                            accent: accentForMode(mode)
                        ) {
                            sessionItems.removeAll { $0.id == item.id }
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

    private var bottomBar: some View {
        VStack(spacing: 10) {
            Divider().opacity(0.6)

            Button {
                // ✅ aquí arrancará tu flujo real (sets/temporizador/etc.)
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(sessionItems.isEmpty ? "Añade ejercicios para empezar" : "Entrenar ahora")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if !sessionItems.isEmpty {
                        Text("\(sessionItems.count)")
                            .font(.caption.bold())
                            .padding(.vertical, 5)
                            .padding(.horizontal, 9)
                            .background(Capsule().fill(Color.white.opacity(0.18)))
                    }
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(accentForMode(mode))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(sessionItems.isEmpty)
            .opacity(sessionItems.isEmpty ? 0.55 : 1)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(TrainingBrand.bg)
    }

    // MARK: - Helpers

    private func subtitleForPlan(_ plan: PlannedSession) -> String {
        let trimmed = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        return plan.tipo.title
    }

    private func map(_ tipo: TrainingSessionType) -> Mode {
        switch tipo {
        case .gimnasio, .rutina, .hiit, .calistenia, .deporte: return .gimnasio
        case .cardio: return .cardio
        case .movilidad, .rehab, .descanso: return .movilidad
        }
    }

    private func accentForPlan(_ plan: PlannedSession) -> Color {
        switch plan.tipo {
        case .gimnasio, .calistenia: return TrainingBrand.action
        case .cardio, .hiit: return TrainingBrand.cardio
        case .movilidad, .rehab, .descanso: return TrainingBrand.mobility
        case .rutina, .deporte: return TrainingBrand.custom
        }
    }

    private func accentForMode(_ m: Mode) -> Color {
        switch m {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        }
    }
}

// MARK: - Draft models

private struct SessionItemDraft: Identifiable, Hashable {
    let id = UUID()
    var exerciseId: UUID? = nil
    var title: String
    var subtitle: String
    var icon: String
}

// MARK: - UI bits

private struct EmptyStateBox: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ModeTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let isOn: Bool
    let accent: Color
    let onTap: () -> Void

    init(_ title: String, _ subtitle: String, _ icon: String, _ isOn: Bool, _ accent: Color, onTap: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isOn = isOn
        self.accent = accent
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(TrainingBrand.softFill(accent))
                        Image(systemName: icon)
                            .font(.headline.bold())
                            .foregroundStyle(accent)
                    }
                    .frame(width: 40, height: 40)
                    Spacer()
                    if isOn {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(accent)
                    }
                }

                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isOn ? accent.opacity(0.10) : Color.gray.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isOn ? accent.opacity(0.35) : Color.gray.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(TrainingBrand.softFill(accent))
                Image(systemName: icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
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
}

private struct SessionItemRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(TrainingBrand.softFill(accent))
                Image(systemName: icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

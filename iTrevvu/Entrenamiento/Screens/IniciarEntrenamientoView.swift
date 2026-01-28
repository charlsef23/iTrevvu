import SwiftUI

struct IniciarEntrenamientoView: View {

    let plan: PlannedSession?

    init(plan: PlannedSession? = nil) {
        self.plan = plan
    }

    enum Mode: String, CaseIterable, Identifiable {
        case gimnasio = "Gimnasio"
        case cardio = "Cardio"
        case movilidad = "Movilidad"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .gimnasio

    // ✅ FIX: ya no recibe client
    @StateObject private var exerciseStore = ExerciseStore()

    // UI state
    @State private var showLibrary = false
    @State private var showFavorites = false

    // ✅ “builder” local (fase 1)
    @State private var sessionItems: [SessionItemDraft] = []

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
        .task {
            // ✅ opcional: precarga una categoría
            await exerciseStore.load(type: .fuerza)
        }
        .onAppear {
            if let plan { mode = map(plan.tipo) }
        }
        .sheet(isPresented: $showLibrary) {
            NavigationStack {
                ExerciseLibraryHubView()
                    .environmentObject(exerciseStore)
                    .navigationTitle("Biblioteca")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cerrar") { showLibrary = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $showFavorites) {
            NavigationStack {
                FavoritesPlaceholderView()
                    .navigationTitle("Favoritos")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cerrar") { showFavorites = false }
                        }
                    }
            }
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

                planMetaRow(plan)
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
                            Text("Elige modo y empieza tu sesión.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    HStack(spacing: 8) {
                        Chip(text: mode.rawValue, icon: "slider.horizontal.3", tint: accentForMode(mode))
                        Chip(text: "Sin plan", icon: "calendar", tint: .secondary)
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

    private func planMetaRow(_ plan: PlannedSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Chip(text: plan.tipo.title, icon: iconForType(plan.tipo), tint: accentForPlan(plan))

                if let mins = plan.duracionMinutos {
                    Chip(text: "\(mins) min", icon: "clock.fill", tint: .secondary)
                }

                if let obj = plan.objetivo, !obj.isEmpty {
                    Chip(text: obj, icon: "target", tint: TrainingBrand.stats)
                }
            }

            if let note = plan.notas, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
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

    // MARK: - Mode Picker (mejorado)

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Modo")
                .font(.headline.bold())

            HStack(spacing: 10) {
                ModeTile(
                    title: "Gimnasio",
                    subtitle: "Fuerza / sets",
                    icon: "dumbbell.fill",
                    isOn: mode == .gimnasio,
                    accent: TrainingBrand.action
                ) { mode = .gimnasio }

                ModeTile(
                    title: "Cardio",
                    subtitle: "Tiempo / ritmo",
                    icon: "figure.run",
                    isOn: mode == .cardio,
                    accent: TrainingBrand.cardio
                ) { mode = .cardio }

                ModeTile(
                    title: "Movilidad",
                    subtitle: "Recuperación",
                    icon: "figure.cooldown",
                    isOn: mode == .movilidad,
                    accent: TrainingBrand.mobility
                ) { mode = .movilidad }
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

            Button {
                showLibrary = true
            } label: {
                ActionRow(
                    title: "Biblioteca de ejercicios",
                    subtitle: "Busca, filtra y añade a tu sesión",
                    icon: "square.grid.2x2.fill",
                    accent: accentForMode(mode)
                )
            }
            .buttonStyle(.plain)

            Button {
                showFavorites = true
            } label: {
                ActionRow(
                    title: "Favoritos",
                    subtitle: "Tus ejercicios guardados",
                    icon: "star.fill",
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
                Text("Sesión")
                    .font(.headline.bold())
                Spacer()

                Button {
                    addQuickItemForMode()
                } label: {
                    Label("Añadir", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(accentForMode(mode))
                .buttonStyle(.plain)
            }

            if sessionItems.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Aún no has añadido ejercicios.")
                        .font(.subheadline.weight(.semibold))
                    Text("Pulsa “Añadir” para crear tu sesión. (Fase 1: local)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.gray.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(sessionItems) { item in
                        SessionItemRow(
                            title: item.title,
                            subtitle: item.subtitle,
                            icon: item.icon,
                            accent: accentForMode(mode),
                            onDelete: {
                                sessionItems.removeAll { $0.id == item.id }
                            }
                        )
                    }
                }
            }

            Divider().opacity(0.6)

            HStack(spacing: 10) {
                Button {
                    showLibrary = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Buscar en biblioteca")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(TrainingBrand.softFill(accentForMode(mode)))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    sessionItems.removeAll()
                } label: {
                    Image(systemName: "trash")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(sessionItems.isEmpty)
                .opacity(sessionItems.isEmpty ? 0.4 : 1)
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
                // Fase 1: aquí arrancas el flujo real de entrenamiento (sets/temporizador/etc.)
                // Por ahora dejamos placeholder “sesión iniciada”
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(sessionItems.isEmpty ? "Añade ejercicios para empezar" : "Empezar sesión")
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

    private func addQuickItemForMode() {
        switch mode {
        case .gimnasio:
            sessionItems.append(.init(title: "Ejercicio (fuerza)", subtitle: "Series · Reps · Peso", icon: "dumbbell.fill"))
        case .cardio:
            sessionItems.append(.init(title: "Cardio", subtitle: "Tiempo · Distancia", icon: "figure.run"))
        case .movilidad:
            sessionItems.append(.init(title: "Movilidad", subtitle: "Tiempo · Rango", icon: "figure.cooldown"))
        }
    }

    // MARK: - Helpers

    private func subtitleForPlan(_ plan: PlannedSession) -> String {
        let trimmed = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        return plan.tipo.title
    }

    private func map(_ tipo: TrainingSessionType) -> Mode {
        switch tipo {
        case .gimnasio, .rutina, .hiit, .calistenia, .deporte:
            return .gimnasio
        case .cardio:
            return .cardio
        case .movilidad, .rehab, .descanso:
            return .movilidad
        }
    }

    private func accentForPlan(_ plan: PlannedSession) -> Color {
        switch plan.tipo {
        case .gimnasio, .calistenia:
            return TrainingBrand.action
        case .cardio, .hiit:
            return TrainingBrand.cardio
        case .movilidad, .rehab, .descanso:
            return TrainingBrand.mobility
        case .rutina, .deporte:
            return TrainingBrand.custom
        }
    }

    private func accentForMode(_ m: Mode) -> Color {
        switch m {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        }
    }

    private func iconForType(_ t: TrainingSessionType) -> String {
        switch t {
        case .gimnasio: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        case .rutina: return "list.bullet.rectangle.portrait"
        case .hiit: return "bolt.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .deporte: return "sportscourt.fill"
        case .rehab: return "cross.case.fill"
        case .descanso: return "bed.double.fill"
        }
    }
}

// MARK: - Draft models (fase 1)

private struct SessionItemDraft: Identifiable, Hashable {
    let id: UUID = UUID()
    var title: String
    var subtitle: String
    var icon: String
}

// MARK: - Small UI components

private struct ModeTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let isOn: Bool
    let accent: Color
    let onTap: () -> Void

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

                Text(title)
                    .font(.subheadline.bold())

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

private struct Chip: View {
    let text: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(tint == .secondary ? .primary : tint)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Capsule().fill(tint.opacity(0.14)))
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
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
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

private struct FavoritesPlaceholderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "star.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Favoritos")
                .font(.title3.bold())
            Text("Aquí mostraremos tus ejercicios favoritos de Supabase.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
        }
        .padding(24)
        .background(TrainingBrand.bg)
    }
}

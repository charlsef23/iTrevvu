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
    @StateObject private var exerciseStore = ExerciseStore(client: SupabaseManager.shared.client)

    @State private var selected: [Exercise] = []
    @State private var showPicker = false

    // ✅ navegación a sesión
    @State private var goSession = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                headerHero
                modePicker
                selectedBlock
                quickActions
                infoBlock

                Spacer(minLength: 40)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Entrenar")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)

        .safeAreaInset(edge: .bottom) {
            TrainingBottomCTA(
                title: selected.isEmpty ? "Selecciona ejercicios" : "Entrenar ahora",
                subtitle: selected.isEmpty
                    ? "Elige ejercicios para empezar"
                    : "\(selected.count) ejercicio(s) · sesión rápida",
                systemImage: selected.isEmpty ? "plus" : "play.fill",
                isEnabled: !selected.isEmpty,
                accent: accentForMode(mode)
            ) {
                goSession = true
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }

        .sheet(isPresented: $showPicker) {
            ExercisePickerView(
                mode: .pick { ex in
                    if !selected.contains(where: { $0.id == ex.id }) {
                        selected.append(ex)
                    }
                },
                type: mapModeToExerciseType(mode)
            )
            .environmentObject(exerciseStore)
        }

        // ✅ Navigation recommended (iOS16+)
        .navigationDestination(isPresented: $goSession) {
            TrainingSessionLiveView(
                mode: mode,
                plan: plan,
                exercises: selected,
                accent: accentForMode(mode)
            )
        }

        .task { await exerciseStore.load(type: .fuerza) }
        .onAppear { if let plan { mode = map(plan.tipo) } }
    }

    // MARK: - Sections

    private var headerHero: some View {
        Group {
            if let plan {
                SportHeroCard(
                    title: "Plan de hoy",
                    subtitle: subtitleForPlan(plan),
                    icon: "checkmark.seal.fill",
                    accent: accentForPlan(plan)
                )
            } else {
                SportHeroCard(
                    title: "Entrenamiento libre",
                    subtitle: "Crea una sesión rápida con ejercicios",
                    icon: "bolt.fill",
                    accent: accentForMode(mode)
                )
            }
        }
    }

    private var selectedBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Ejercicios")
                    .font(.headline.bold())

                Spacer()

                Button { showPicker = true } label: {
                    Label("Añadir", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(accentForMode(mode))
                .buttonStyle(.plain)
            }

            if selected.isEmpty {
                EmptySelectCard(
                    title: "Aún no has añadido ejercicios",
                    subtitle: "Pulsa “Añadir” para elegir ejercicios y entrenar ahora",
                    accent: accentForMode(mode)
                ) { showPicker = true }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selected, id: \.id) { ex in
                            SelectedExerciseChip(
                                title: ex.nombre,
                                subtitle: ex.tipo.title,
                                accent: accentForMode(mode)
                            ) {
                                selected.removeAll(where: { $0.id == ex.id })
                            }
                        }
                    }
                    .padding(.vertical, 2)
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

    private var quickActions: some View {
        VStack(spacing: 10) {

            Button { showPicker = true } label: {
                ActionRow(
                    title: "Seleccionar ejercicios",
                    subtitle: "Busca, filtra y favoritos",
                    icon: "square.grid.2x2.fill",
                    accent: accentForMode(mode)
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                ExerciseLibraryHubView()
                    .environmentObject(exerciseStore)
            } label: {
                ActionRow(
                    title: "Biblioteca completa",
                    subtitle: "Explora por categorías",
                    icon: "magnifyingglass",
                    accent: accentForMode(mode)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sesión rápida")
                .font(.headline.bold())
            Text("En FASE 4 añadimos sets, descanso, temporizador y guardado en Supabase.")
                .font(.subheadline)
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

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Modo")
                .font(.headline.bold())

            HStack(spacing: 10) {
                ModeChip(title: "Gimnasio", isOn: mode == .gimnasio, accent: TrainingBrand.action) { mode = .gimnasio }
                ModeChip(title: "Cardio", isOn: mode == .cardio, accent: TrainingBrand.cardio) { mode = .cardio }
                ModeChip(title: "Movilidad", isOn: mode == .movilidad, accent: TrainingBrand.mobility) { mode = .movilidad }
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

    // MARK: - Helpers

    private func subtitleForPlan(_ plan: PlannedSession) -> String {
        let trimmed = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? plan.tipo.title : trimmed
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

    private func mapModeToExerciseType(_ m: Mode) -> ExerciseType {
        switch m {
        case .gimnasio: return .fuerza
        case .cardio: return .cardio
        case .movilidad: return .movilidad
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

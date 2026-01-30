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
    @StateObject private var sessionStore = TrainingSessionStore()

    @State private var selected: [Exercise] = []
    @State private var showPicker = false
    @State private var goSession = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            content
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 90)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Entrenar ahora")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { trailingMenu }
        .tint(.primary)
        .safeAreaInset(edge: .bottom) { bottomCTA }
        .sheet(isPresented: $showPicker) { pickerSheet }
        .navigationDestination(isPresented: $goSession) { sessionDestination }
        .task { await exerciseStore.load(type: .fuerza) }
        .onAppear {
            if let plan { mode = map(plan.tipo) }
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            hero
            modeCard
            selectedCard
            quickActionsCard
            tipsCard
        }
    }

    // MARK: - Toolbar

    private var trailingMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    selected.removeAll()
                } label: {
                    Label("Limpiar selección", systemImage: "trash")
                }
                .disabled(selected.isEmpty)

                Button {
                    showPicker = true
                } label: {
                    Label("Añadir ejercicios", systemImage: "plus")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

    // MARK: - Bottom CTA

    private var bottomCTA: some View {
        TrainingBottomCTA(
            title: selected.isEmpty ? "Selecciona ejercicios" : "Entrenar ahora",
            subtitle: selected.isEmpty ? "Añade ejercicios para empezar" : subtitleForCTA,
            systemImage: selected.isEmpty ? "plus" : "play.fill",
            isEnabled: !selected.isEmpty,
            accent: accentForMode(mode)
        ) {
            sessionStore.start(title: planTitleOrDefault)
            selected.forEach { sessionStore.addExercise($0) }
            goSession = true
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Sheet

    private var pickerSheet: some View {
        ExercisePickerView(
            mode: .pick { ex in
                if !selected.contains(where: { $0.id == ex.id }) {
                    withAnimation(.snappy(duration: 0.25)) {
                        selected.append(ex)
                    }
                }
            },
            type: mapModeToExerciseType(mode)
        )
        .environmentObject(exerciseStore)
    }

    // MARK: - Destination (IMPORTANT)

    private var sessionDestination: some View {
        TrainingSessionLiveView(
            store: sessionStore,
            mode: mode,
            plan: plan,
            exercises: selected,
            accent: accentForMode(mode)
        )
    }

    // MARK: - Hero

    private var hero: some View {
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
                    title: "Sesión rápida",
                    subtitle: "Elige ejercicios y empieza en 10 segundos",
                    icon: "bolt.fill",
                    accent: accentForMode(mode)
                )
            }
        }
    }

    // MARK: - Mode card

    private var modeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Modo").font(.headline.bold())
                Spacer()
                Text(mode.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                ModeChip(title: "Gimnasio", isOn: mode == .gimnasio, accent: TrainingBrand.action) {
                    withAnimation(.snappy(duration: 0.2)) { mode = .gimnasio }
                }
                ModeChip(title: "Cardio", isOn: mode == .cardio, accent: TrainingBrand.cardio) {
                    withAnimation(.snappy(duration: 0.2)) { mode = .cardio }
                }
                ModeChip(title: "Movilidad", isOn: mode == .movilidad, accent: TrainingBrand.mobility) {
                    withAnimation(.snappy(duration: 0.2)) { mode = .movilidad }
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

    // MARK: - Selected card

    private var selectedCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text("Ejercicios").font(.headline.bold())

                if !selected.isEmpty {
                    Text("\(selected.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Capsule().fill(Color.gray.opacity(0.12)))
                }

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
                    subtitle: "Pulsa “Añadir” y elige tus ejercicios para entrenar ahora.",
                    accent: accentForMode(mode)
                ) { showPicker = true }
            } else {
                selectedChips
                Divider().opacity(0.6)
                Text(suggestionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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

    private var selectedChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(selected, id: \.id) { ex in
                    SelectedExerciseChip(
                        title: ex.nombre,
                        subtitle: ex.tipo.title,
                        accent: accentForMode(mode)
                    ) {
                        withAnimation(.snappy(duration: 0.2)) {
                            selected.removeAll(where: { $0.id == ex.id })
                        }
                    }
                }

                Button {
                    withAnimation(.snappy(duration: 0.2)) { selected.removeAll() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                        Text("Limpiar").font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(Color.gray.opacity(0.10)))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Quick actions

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Acciones").font(.headline.bold())

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
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    // MARK: - Tips

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Consejo").font(.headline.bold())
            Text("Empieza con 3–6 ejercicios. En FASE 4 añadimos sets, descanso y guardado real en Supabase.")
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

    // MARK: - Helpers

    private var subtitleForCTA: String {
        if let p = plan {
            return "\(selected.count) ejercicio(s) · \(subtitleForPlan(p))"
        }
        return "\(selected.count) ejercicio(s) · sesión rápida"
    }

    private var planTitleOrDefault: String {
        if let p = plan {
            let t = subtitleForPlan(p).trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? "Sesión" : t
        }
        return "Sesión"
    }

    private var suggestionText: String {
        switch mode {
        case .gimnasio: return "Sugerencia: press + tirón + pierna + accesorio (4–6 ejercicios)."
        case .cardio: return "Sugerencia: 1 principal + 1 accesorio (core o movilidad)."
        case .movilidad: return "Sugerencia: 6–10 minutos por bloque (cadera, espalda, hombros)."
        }
    }

    private func subtitleForPlan(_ plan: PlannedSession) -> String {
        let trimmed = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? plan.tipo.title : trimmed
    }

    private func map(_ tipo: TrainingSessionType) -> Mode {
        switch tipo {
        case .gimnasio, .rutina, .hiit, .calistenia, .deporte: return .gimnasio
        case .cardio: return .cardio
        case .movilidad, .rehab, .descanso: return .movilidad
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

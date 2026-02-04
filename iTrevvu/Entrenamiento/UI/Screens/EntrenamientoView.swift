import SwiftUI

struct EntrenamientoView: View {

    @State private var selectedDate: Date = .now
    @State private var calendarMode: CalendarDisplayMode = .week
    @State private var showPlanSheet = false

    @State private var presentTrain = false
    @State private var planToTrain: PlannedSession? = nil

    @StateObject private var planner = TrainingPlannerStore(client: SupabaseManager.shared.client)

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    TrainingCalendarCard(
                        selectedDate: $selectedDate,
                        mode: $calendarMode,
                        onPlanTap: { showPlanSheet = true }
                    )
                    .environmentObject(planner)

                    dayPlanBlock

                    quickActionsBlock

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .background(TrainingBrand.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
            .tint(.primary)

            // ✅ CTA fijo abajo (premium)
            .safeAreaInset(edge: .bottom) {
                TrainingBottomCTA(
                    title: "Entrenar ahora",
                    subtitle: bottomSubtitle,
                    systemImage: "play.fill",
                    isEnabled: true,
                    accent: bottomAccent
                ) {
                    presentTrain = true
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }

            // ✅ Sheet planificar/editar
            .sheet(isPresented: $showPlanSheet) {
                PlanTrainingSheet(
                    date: selectedDate,
                    existing: planner.firstSession(for: selectedDate)
                )
                .environmentObject(planner)
            }

            // ✅ navegación moderna (sin deprecated)
            .navigationDestination(isPresented: $presentTrain) {
                EntrenamientoRapidoView()
            }

            // ✅ carga
            .task {
                await planner.bootstrap()
                await planner.loadRange(around: selectedDate)
                planToTrain = planner.firstSession(for: selectedDate)
            }
            .onChange(of: selectedDate) { _, newValue in
                Task {
                    await planner.loadRange(around: newValue)
                    planToTrain = planner.firstSession(for: newValue)
                }
            }
        }
    }

    // MARK: - Plan del día

    private var dayPlanBlock: some View {
        Group {
            if let session = planner.firstSession(for: selectedDate) {
                PlannedWorkoutDayCard(
                    plan: session,
                    onTrain: {
                        planToTrain = session
                        presentTrain = true
                    },
                    onEdit: {
                        showPlanSheet = true
                    }
                )
            } else {
                EmptyPlanCardInline {
                    showPlanSheet = true
                }
            }
        }
        .animation(.snappy(duration: 0.25), value: planner.firstSession(for: selectedDate)?.id)
    }

    // MARK: - Acciones rápidas

    private var quickActionsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Acciones rápidas")
                    .font(.headline.bold())
                Spacer()
            }

            VStack(spacing: 10) {

                Button {
                    showPlanSheet = true
                } label: {
                    ActionRow(
                        title: "Planificar",
                        subtitle: "Crea una sesión para este día",
                        icon: "calendar.badge.plus",
                        accent: TrainingBrand.custom
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    ExerciseLibraryHubView()
                } label: {
                    ActionRow(
                        title: "Biblioteca de ejercicios",
                        subtitle: "Buscar, filtrar y favoritos",
                        icon: "square.grid.2x2.fill",
                        accent: TrainingBrand.action
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    Text("Historial (pendiente)")
                        .foregroundStyle(.secondary)
                        .padding()
                        .navigationTitle("Historial")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    ActionRow(
                        title: "Historial",
                        subtitle: "Revisa sesiones anteriores",
                        icon: "clock.arrow.circlepath",
                        accent: TrainingBrand.stats
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

    // MARK: - CTA helpers

    private var bottomSubtitle: String {
        if let s = planToTrain {
            let name = s.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = name.isEmpty ? s.tipo.title : name
            return "Plan del día · \(title)"
        }
        return "Sesión rápida · elige ejercicios y empieza"
    }

    private var bottomAccent: Color {
        guard let s = planToTrain else { return TrainingBrand.action }
        switch s.tipo {
        case .gimnasio, .calistenia: return TrainingBrand.action
        case .cardio, .hiit: return TrainingBrand.cardio
        case .movilidad, .rehab, .descanso: return TrainingBrand.mobility
        case .rutina, .deporte: return TrainingBrand.custom
        }
    }
}

// MARK: - Empty Plan Inline

private struct EmptyPlanCardInline: View {
    let onPlan: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(TrainingBrand.custom))
                    Image(systemName: "calendar.badge.plus")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(TrainingBrand.custom)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Sin sesión planificada")
                        .font(.headline.bold())
                    Text("Planifica una sesión para este día o empieza una rápida.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Button {
                onPlan()
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Planificar ahora")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(TrainingBrand.custom)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
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

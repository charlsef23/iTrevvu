import SwiftUI

struct EntrenamientoView: View {

    @State private var selectedDate: Date = .now
    @State private var calendarMode: CalendarDisplayMode = .week
    @State private var showPlanSheet = false

    @State private var navigateToTrain = false
    @State private var planToTrain: PlannedSession? = nil

    @StateObject private var planner = TrainingPlannerStore(client: SupabaseManager.shared.client)

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    TrainingCalendarCard(
                        selectedDate: $selectedDate,
                        mode: $calendarMode,
                        onPlanTap: { showPlanSheet = true }
                    )
                    .environmentObject(planner)

                    // ✅ Sesión planificada del día
                    if let session = planner.firstSession(for: selectedDate) {
                        PlannedWorkoutDayCard(
                            plan: session,
                            onTrain: {
                                planToTrain = session
                                navigateToTrain = true
                            },
                            onEdit: { showPlanSheet = true }
                        )
                    } else {
                        EmptyPlanCardInline { showPlanSheet = true }
                    }

                    // ✅ Entrenamiento libre
                    NavigationLink {
                        IniciarEntrenamientoView(plan: nil)
                    } label: {
                        PrimaryCTA(
                            title: "Iniciar entrenamiento",
                            subtitle: "Gimnasio o cardio · con temporizador y series",
                            systemImage: "play.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(TrainingBrand.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
            .tint(.primary)

            // ✅ Sheet planificar/editar
            .sheet(isPresented: $showPlanSheet) {
                PlanTrainingSheet(
                    date: selectedDate,
                    existing: planner.firstSession(for: selectedDate)
                )
                .environmentObject(planner)
            }

            // ✅ Navigation recommended (iOS16+)
            .navigationDestination(isPresented: $navigateToTrain) {
                IniciarEntrenamientoView(plan: planToTrain)
            }

            // ✅ Carga
            .task {
                await planner.bootstrap()
                await planner.loadRange(around: selectedDate)
            }
            .onChange(of: selectedDate) { _, newValue in
                Task { await planner.loadRange(around: newValue) }
            }
        }
    }
}

private struct EmptyPlanCardInline: View {
    let onPlan: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sin entrenamiento planificado")
                        .font(.headline.bold())
                    Text("Planifica una sesión para este día.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Planificar") { onPlan() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TrainingBrand.stats)
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
}

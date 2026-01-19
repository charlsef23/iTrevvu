import SwiftUI

struct EntrenamientoView: View {

    @State private var selectedDate: Date = .now
    @State private var calendarMode: CalendarDisplayMode = .week
    @State private var showPlanSheet = false

    // Stores Supabase
    @StateObject private var planner = TrainingPlannerStore(client: SupabaseManager.shared.client)
    @StateObject private var exerciseStore = ExerciseStore(client: SupabaseManager.shared.client)

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    // Calendario
                    TrainingCalendarCard(
                        selectedDate: $selectedDate,
                        mode: $calendarMode
                    )
                    .environmentObject(planner)

                    // Plan del día seleccionado
                    if let plan = planner.plan(for: selectedDate) {
                        NavigationLink {
                            IniciarEntrenamientoView(plan: plan)
                        } label: {
                            PlannedWorkoutDayCard(
                                plan: plan,
                                onTrain: { },
                                onEdit: { showPlanSheet = true }
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        EmptyPlanCard {
                            showPlanSheet = true
                        }
                    }

                    // CTA (siempre)
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

                    // Entrenamientos (carrusel)
                    SectionHeader(title: "Entrenamientos", actionTitle: "Ver todo", tint: .secondary) { }

                    TrainingCategoryCarousel(items: [
                        .init(
                            title: "Gimnasio",
                            subtitle: "Fuerza, hipertrofia, full body…",
                            systemImage: "dumbbell.fill",
                            tint: TrainingBrand.action,
                            destination: AnyView(GimnasioHubView())
                        ),
                        .init(
                            title: "Cardio",
                            subtitle: "Correr, bici, HIIT, intervalos…",
                            systemImage: "figure.run",
                            tint: TrainingBrand.cardio,
                            destination: AnyView(CardioHubView())
                        ),
                        .init(
                            title: "Movilidad",
                            subtitle: "Estiramientos y recuperación",
                            systemImage: "figure.cooldown",
                            tint: TrainingBrand.mobility,
                            destination: AnyView(MovilidadView())
                        )
                    ])

                    // Rutinas
                    SectionHeader(title: "Rutinas", actionTitle: "Explorar", tint: TrainingBrand.custom) { }

                    VStack(spacing: 12) {
                        NavigationLink { RutinaDetalleView(title: "Fuerza · Parte superior") } label: {
                            RoutineCard(title: "Fuerza · Parte superior", subtitle: "6 ejercicios · 45 min", tag: "Recomendada")
                        }
                        .buttonStyle(.plain)

                        NavigationLink { RutinaDetalleView(title: "Hipertrofia · Pierna") } label: {
                            RoutineCard(title: "Hipertrofia · Pierna", subtitle: "7 ejercicios · 55 min", tag: "Popular")
                        }
                        .buttonStyle(.plain)

                        NavigationLink { RutinaDetalleView(title: "Full Body · Express") } label: {
                            RoutineCard(title: "Full Body · Express", subtitle: "5 ejercicios · 30 min", tag: "Rápida")
                        }
                        .buttonStyle(.plain)
                    }

                    // Rutinas personalizadas
                    SectionHeader(title: "Rutinas personalizadas", actionTitle: "Crear", tint: TrainingBrand.custom) { }
                    CustomRoutinesCard()

                    // Estadísticas
                    SectionHeader(title: "Estadísticas", actionTitle: "Ver estadísticas", tint: TrainingBrand.stats) { }
                    NavigationLink { EjercicioEstadisticasHubView() } label: { ExerciseStatsPreviewCard() }
                        .buttonStyle(.plain)

                    // Historial
                    SectionHeader(title: "Historial", actionTitle: "Ver todo", tint: .secondary) { }

                    VStack(spacing: 10) {
                        NavigationLink { HistorialDetalleView(title: "Entrenamiento de fuerza") } label: {
                            HistoryRow(title: "Entrenamiento de fuerza", subtitle: "Ayer · 42 min", icon: "dumbbell.fill")
                        }
                        .buttonStyle(.plain)

                        NavigationLink { HistorialDetalleView(title: "Cardio · Carrera") } label: {
                            HistoryRow(title: "Cardio · Carrera", subtitle: "Hace 3 días · 28 min", icon: "figure.run")
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(TrainingBrand.bg)
            .navigationBarTitleDisplayMode(.inline)

            // ✅ Ultra limpia (0 espacio arriba)
            .toolbar {
                ToolbarItem(placement: .principal) { EmptyView() }
            }

            .tint(.primary)
            .sheet(isPresented: $showPlanSheet) {
                PlanTrainingSheet(date: selectedDate, existing: planner.plan(for: selectedDate))
                    .environmentObject(planner)
            }
            .task {
                await planner.bootstrap()
                await planner.loadRange(around: selectedDate)

                await exerciseStore.bootstrap()
            }
            .onChange(of: selectedDate) { _, newValue in
                Task { await planner.loadRange(around: newValue) }
            }
        }
    }
}

private struct EmptyPlanCard: View {
    let onPlan: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sin entrenamiento planificado")
                        .font(.headline.bold())
                    Text("Planifica una rutina o sesión para este día.")
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

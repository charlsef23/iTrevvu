import SwiftUI

struct EntrenamientoView: View {

    @State private var selectedDate: Date = .now

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    TrainingCalendarCard(selectedDate: $selectedDate)

                    NavigationLink {
                        IniciarEntrenamientoView()
                    } label: {
                        PrimaryCTA(
                            title: "Iniciar entrenamiento",
                            subtitle: "Gimnasio o cardio · con temporizador y series",
                            systemImage: "play.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    SectionHeader(title: "Entrenamientos", actionTitle: "Ver todo") { }

                    TrainingCategoryCarousel(items: [
                        .init(
                            title: "Gimnasio",
                            subtitle: "Fuerza, hipertrofia, full body…",
                            systemImage: "dumbbell.fill",
                            tint: TrainingBrand.strength,      // 🔴
                            destination: AnyView(GimnasioHubView())
                        ),
                        .init(
                            title: "Cardio",
                            subtitle: "Correr, bici, HIIT, intervalos…",
                            systemImage: "figure.run",
                            tint: TrainingBrand.cardio,        // 🟠
                            destination: AnyView(CardioHubView())
                        ),
                        .init(
                            title: "Movilidad",
                            subtitle: "Estiramientos y recuperación",
                            systemImage: "figure.cooldown",
                            tint: TrainingBrand.mobility,      // 🟢
                            destination: AnyView(MovilidadView())
                        )
                    ])

                    SectionHeader(title: "Rutinas", actionTitle: "Explorar") { }

                    VStack(spacing: 12) {
                        NavigationLink { RutinaDetalleView(title: "Fuerza · Parte superior") } label: {
                            RoutineCard(
                                title: "Fuerza · Parte superior",
                                subtitle: "6 ejercicios · 45 min",
                                tag: "Recomendada"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink { RutinaDetalleView(title: "Hipertrofia · Pierna") } label: {
                            RoutineCard(
                                title: "Hipertrofia · Pierna",
                                subtitle: "7 ejercicios · 55 min",
                                tag: "Popular"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink { RutinaDetalleView(title: "Full Body · Express") } label: {
                            RoutineCard(
                                title: "Full Body · Express",
                                subtitle: "5 ejercicios · 30 min",
                                tag: "Rápida"
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    SectionHeader(title: "Rutinas personalizadas", actionTitle: "Crear") { }

                    CustomRoutinesCard()

                    SectionHeader(title: "Estadísticas", actionTitle: "Ver estadísticas") { }

                    NavigationLink {
                        EjercicioEstadisticasHubView()
                    } label: {
                        ExerciseStatsPreviewCard()
                    }
                    .buttonStyle(.plain)

                    SectionHeader(title: "Historial", actionTitle: "Ver todo") { }

                    VStack(spacing: 10) {
                        NavigationLink { HistorialDetalleView(title: "Entrenamiento de fuerza") } label: {
                            HistoryRow(
                                title: "Entrenamiento de fuerza",
                                subtitle: "Ayer · 42 min",
                                icon: "dumbbell.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink { HistorialDetalleView(title: "Cardio · Carrera") } label: {
                            HistoryRow(
                                title: "Cardio · Carrera",
                                subtitle: "Hace 3 días · 28 min",
                                icon: "figure.run"
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(TrainingBrand.bg)
            .navigationTitle("Entrenamiento")
            .navigationBarTitleDisplayMode(.inline)
            .tint(.primary)
        }
    }
}

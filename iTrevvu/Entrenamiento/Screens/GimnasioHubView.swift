import SwiftUI

struct GimnasioHubView: View {

    private let accent = TrainingBrand.action

    struct GymOption: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let destination: AnyView
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: "Gimnasio",
                    subtitle: "Fuerza · Hipertrofia · Powerbuilding",
                    icon: "dumbbell.fill",
                    accent: accent
                )

                SectionHeader(title: "Empezar", actionTitle: "Ver todo", tint: accent) { }

                VStack(spacing: 12) {
                    ForEach(gymOptions) { opt in
                        NavigationLink { opt.destination } label: {
                            HubRowCard(
                                title: opt.title,
                                subtitle: opt.subtitle,
                                icon: opt.icon,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                SectionHeader(title: "Plantillas rápidas", actionTitle: "Usar", tint: .secondary) { }

                VStack(spacing: 12) {
                    NavigationLink { RutinaDetalleView(title: "Full Body · Fuerza") } label: {
                        TemplateCard(title: "Full Body · Fuerza", subtitle: "5 ejercicios · 45 min", tag: "Top", accent: accent)
                    }
                    .buttonStyle(.plain)

                    NavigationLink { RutinaDetalleView(title: "Push/Pull/Legs") } label: {
                        TemplateCard(title: "Push / Pull / Legs", subtitle: "3 días · 60 min", tag: "Clásica", accent: accent)
                    }
                    .buttonStyle(.plain)

                    NavigationLink { RutinaDetalleView(title: "Torso/Pierna") } label: {
                        TemplateCard(title: "Torso / Pierna", subtitle: "4 días · 55 min", tag: "Eficiente", accent: accent)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Gimnasio")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }

    private var gymOptions: [GymOption] {
        [
            .init(
                title: "Entrenamiento libre",
                subtitle: "Ejercicios, series y descansos",
                icon: "square.grid.2x2.fill",
                destination: AnyView(IniciarEntrenamientoView())
            ),
            .init(
                title: "Elegir tipo",
                subtitle: "Fuerza · Hipertrofia · Full body",
                icon: "slider.horizontal.3",
                destination: AnyView(GimnasioTipoView())
            ),
            .init(
                title: "Mis rutinas",
                subtitle: "Creadas por ti o guardadas",
                icon: "bookmark.fill",
                destination: AnyView(MisRutinasView())
            )
        ]
    }
}

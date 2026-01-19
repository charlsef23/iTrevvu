import SwiftUI

struct CardioHubView: View {

    private let accent = TrainingBrand.cardio

    private struct CardioOption: Identifiable {
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
                    title: "Cardio",
                    subtitle: "Ritmo · Intervalos · Zonas",
                    icon: "figure.run",
                    accent: accent
                )

                SectionHeader(title: "Empezar", actionTitle: "Ver todo", tint: accent) { }

                VStack(spacing: 12) {
                    ForEach(options) { opt in
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

                SectionHeader(title: "Sesiones sugeridas", actionTitle: "Guardar", tint: .secondary) { }

                VStack(spacing: 12) {
                    NavigationLink { RutinaDetalleView(title: "Intervalos · 30/30") } label: {
                        TemplateCard(title: "Intervalos · 30/30", subtitle: "20 min · alta intensidad", tag: "HIIT", accent: accent)
                    }.buttonStyle(.plain)

                    NavigationLink { RutinaDetalleView(title: "Rodaje suave · Zona 2") } label: {
                        TemplateCard(title: "Rodaje suave · Zona 2", subtitle: "35 min · base aeróbica", tag: "Z2", accent: accent)
                    }.buttonStyle(.plain)

                    NavigationLink { RutinaDetalleView(title: "Fartlek") } label: {
                        TemplateCard(title: "Fartlek", subtitle: "25 min · cambios de ritmo", tag: "Mixto", accent: accent)
                    }.buttonStyle(.plain)
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Cardio")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }

    private var options: [CardioOption] {
        [
            .init(
                title: "Iniciar sesión",
                subtitle: "Tiempo · distancia · ritmo",
                icon: "play.fill",
                destination: AnyView(IniciarEntrenamientoView())
            ),
            .init(
                title: "Elegir tipo",
                subtitle: "Correr · bici · HIIT · intervalos",
                icon: "slider.horizontal.3",
                destination: AnyView(CardioTipoView())
            ),
            .init(
                title: "Ver estadísticas",
                subtitle: "Zonas · ritmos · sesiones",
                icon: "chart.line.uptrend.xyaxis",
                destination: AnyView(EjercicioEstadisticasHubView())
            )
        ]
    }
}

import SwiftUI

struct MovilidadView: View {

    private let accent = TrainingBrand.mobility

    struct MobilityFlow: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let minutes: Int
        let icon: String
    }

    private let flows: [MobilityFlow] = [
        .init(title: "Descarga post-gym", subtitle: "Cadera · espalda · hombro", minutes: 10, icon: "figure.cooldown"),
        .init(title: "Movilidad mañana", subtitle: "Activación suave", minutes: 8, icon: "sun.max.fill"),
        .init(title: "Espalda y cuello", subtitle: "Pantallas · tensión", minutes: 12, icon: "person.fill.turn.right"),
        .init(title: "Piernas", subtitle: "Isquios · glúteo · tobillo", minutes: 14, icon: "figure.walk")
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: "Movilidad",
                    subtitle: "Recuperación · flexibilidad · bienestar",
                    icon: "figure.cooldown",
                    accent: accent
                )

                SectionHeader(title: "Flujos recomendados", actionTitle: "Ver todo", tint: accent) { }

                LazyVStack(spacing: 12) {
                    ForEach(flows) { flow in
                        NavigationLink {
                            RutinaDetalleView(title: "Movilidad · \(flow.title)")
                        } label: {
                            MobilityCard(flow: flow, accent: accent)
                        }
                        .buttonStyle(.plain)
                    }
                }

                SectionHeader(title: "Consejo del día", actionTitle: nil, tint: nil) { }

                TipCard(
                    title: "Respira lento",
                    subtitle: "Inhala 4s, exhala 6s. Mejoras tono parasimpático y relajación muscular.",
                    accent: accent
                )

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Movilidad")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }
}

private struct MobilityCard: View {
    let flow: MovilidadView.MobilityFlow
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(TrainingBrand.softFill(accent))
                Image(systemName: flow.icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(flow.title).font(.headline.bold())
                Text(flow.subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(flow.minutes) min")
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(TrainingBrand.softFill(accent))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }
}

private struct TipCard: View {
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(accent)
                Text(title)
                    .font(.headline.bold())
                Spacer()
            }
            Text(subtitle)
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
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }
}

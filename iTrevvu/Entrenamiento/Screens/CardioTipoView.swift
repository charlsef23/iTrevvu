import SwiftUI

struct CardioTipoView: View {

    private let accent = TrainingBrand.cardio

    struct TypeItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let details: String
    }

    private let items: [TypeItem] = [
        .init(title: "Correr", subtitle: "Ritmo · distancia · cadencia", icon: "figure.run", details: "Rodaje, series, fartlek"),
        .init(title: "Bicicleta", subtitle: "Potencia · cadencia · Zonas", icon: "bicycle", details: "Rodillo o exterior"),
        .init(title: "HIIT", subtitle: "Alta intensidad", icon: "bolt.heart.fill", details: "Corto y explosivo"),
        .init(title: "Intervalos", subtitle: "Estructurado por tiempo", icon: "timer", details: "Tabatas / 30-30"),
        .init(title: "Caminata", subtitle: "Recuperación activa", icon: "figure.walk", details: "Zona 1–2")
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {

                SportHeroCard(
                    title: "Elige un tipo",
                    subtitle: "Configura temporizador y objetivo",
                    icon: "slider.horizontal.3",
                    accent: accent
                )

                LazyVStack(spacing: 12) {
                    ForEach(items) { it in
                        NavigationLink {
                            RutinaDetalleView(title: "Cardio · \(it.title)")
                        } label: {
                            CardioTypeCard(item: it, accent: accent)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Tipos de cardio")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }
}

private struct CardioTypeCard: View {
    let item: CardioTipoView.TypeItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(accent))
                    Image(systemName: item.icon)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title).font(.headline.bold())
                    Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(item.details)
                .font(.caption)
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

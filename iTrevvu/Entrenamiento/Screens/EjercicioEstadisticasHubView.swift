import SwiftUI

struct EjercicioEstadisticasHubView: View {

    private let accent = TrainingBrand.stats

    struct Metric: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let subtitle: String
        let icon: String
        let destination: AnyView
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: "Estadísticas",
                    subtitle: "Volumen · sesiones · progreso",
                    icon: "chart.line.uptrend.xyaxis",
                    accent: accent
                )

                SectionHeader(title: "Resumen", actionTitle: "Ver detalle", tint: accent) { }
                ExerciseStatsPreviewCard()

                SectionHeader(title: "Métricas", actionTitle: nil, tint: nil) { }

                VStack(spacing: 12) {
                    ForEach(metrics) { m in
                        NavigationLink { m.destination } label: {
                            MetricCard(metric: m, accent: accent)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Estadísticas")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }

    private var metrics: [Metric] {
        [
            .init(
                title: "Volumen",
                value: "12.4K kg",
                subtitle: "Últimos 30 días",
                icon: "scalemass.fill",
                destination: AnyView(EjercicioStatsDetalleView(metricTitle: "Volumen"))
            ),
            .init(
                title: "Sesiones",
                value: "18",
                subtitle: "Frecuencia",
                icon: "calendar",
                destination: AnyView(EjercicioStatsDetalleView(metricTitle: "Sesiones"))
            ),
            .init(
                title: "PRs",
                value: "3",
                subtitle: "Récords",
                icon: "medal.fill",
                destination: AnyView(EjercicioStatsDetalleView(metricTitle: "PRs"))
            )
        ]
    }
}

private struct MetricCard: View {
    let metric: EjercicioEstadisticasHubView.Metric
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(TrainingBrand.softFill(accent))
                Image(systemName: metric.icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.title).font(.headline.bold())
                Text(metric.subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Text(metric.value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
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

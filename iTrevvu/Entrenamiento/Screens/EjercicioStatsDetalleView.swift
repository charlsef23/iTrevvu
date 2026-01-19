import SwiftUI

struct EjercicioStatsDetalleView: View {

    let metricTitle: String
    private let accent = TrainingBrand.stats

    private struct Point: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
    }

    private var points: [Point] {
        [
            .init(label: "Sem 1", value: 2.4),
            .init(label: "Sem 2", value: 3.1),
            .init(label: "Sem 3", value: 2.9),
            .init(label: "Sem 4", value: 4.0)
        ]
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: metricTitle,
                    subtitle: "Tendencia · comparativa",
                    icon: "chart.bar.fill",
                    accent: accent
                )

                StatInsightCard(
                    title: "Insight",
                    subtitle: "Vas mejorando en consistencia. Mantén 3–4 sesiones/semana.",
                    accent: accent
                )

                SectionHeader(title: "Últimas semanas", actionTitle: nil, tint: nil) { }

                VStack(spacing: 10) {
                    ForEach(points) { p in
                        TrendRow(label: p.label, value: p.value, accent: accent)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle(metricTitle)
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }
}

private struct StatInsightCard: View {
    let title: String
    let subtitle: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(accent)
                Text(title).font(.headline.bold())
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

private struct TrendRow: View {
    let label: String
    let value: Double
    let accent: Color

    var body: some View {
        HStack {
            Text(label).font(.subheadline.weight(.semibold))
            Spacer()
            Text(String(format: "%.1f", value))
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(TrainingBrand.softFill(accent))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 5, y: 3)
    }
}

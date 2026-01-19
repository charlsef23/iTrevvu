import SwiftUI

struct HistorialDetalleView: View {

    let title: String

    struct HistoryLine: Identifiable {
        let id = UUID()
        let name: String
        let value: String
        let detail: String
    }

    private let lines: [HistoryLine] = [
        .init(name: "Duración", value: "42 min", detail: "Tiempo total"),
        .init(name: "Volumen", value: "6.2K kg", detail: "Suma de series"),
        .init(name: "PRs", value: "1", detail: "Récords en sesión")
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: title,
                    subtitle: "Detalle de sesión",
                    icon: "clock.arrow.circlepath",
                    accent: Color.gray
                )

                SectionHeader(title: "Resumen", actionTitle: nil, tint: nil) { }

                VStack(spacing: 10) {
                    ForEach(lines) { l in
                        HistoryDetailRow(line: l)
                    }
                }

                SectionHeader(title: "Notas", actionTitle: "Editar", tint: .secondary) { }

                NoteCard(text: "Me sentí fuerte en sentadilla. Mejorar técnica en press banca.")

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }
}

private struct HistoryDetailRow: View {
    let line: HistorialDetalleView.HistoryLine

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(line.name).font(.headline.weight(.semibold))
                Text(line.detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(line.value).font(.headline.bold())
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

private struct NoteCard: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(TrainingBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
            )
            .shadow(color: TrainingBrand.shadow, radius: 5, y: 3)
    }
}

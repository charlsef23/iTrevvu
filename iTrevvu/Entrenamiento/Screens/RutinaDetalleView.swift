import SwiftUI

struct RutinaDetalleView: View {

    let title: String
    private let accent = TrainingBrand.custom

    struct SetLine: Identifiable {
        let id = UUID()
        let name: String
        let sets: String
        let rest: String
    }

    private var plan: [SetLine] {
        [
            .init(name: "Calentamiento", sets: "5 min", rest: "—"),
            .init(name: "Ejercicio 1", sets: "4x8", rest: "90s"),
            .init(name: "Ejercicio 2", sets: "4x10", rest: "75s"),
            .init(name: "Ejercicio 3", sets: "3x12", rest: "60s"),
            .init(name: "Core", sets: "3x", rest: "45s")
        ]
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: title,
                    subtitle: "Estructura sugerida · editable",
                    icon: "list.bullet.rectangle.portrait",
                    accent: accent
                )

                SectionHeader(title: "Plan", actionTitle: "Editar", tint: accent) { }

                VStack(spacing: 10) {
                    ForEach(plan) { line in
                        PlanRow(line: line, accent: accent)
                    }
                }

                Button {
                    // Puedes conectar esto con tu flujo real de iniciar entrenamiento con esta rutina
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Iniciar con esta rutina")
                            .font(.headline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Rutina")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }
}

private struct PlanRow: View {
    let line: RutinaDetalleView.SetLine
    let accent: Color

    var body: some View {
        HStack {
            Text(line.name)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text(line.sets)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(TrainingBrand.softFill(accent))
                .clipShape(Capsule())

            Text(line.rest)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .trailing)
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

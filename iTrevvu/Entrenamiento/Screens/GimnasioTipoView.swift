import SwiftUI

struct GimnasioTipoView: View {

    private let accent = TrainingBrand.action

    struct TypeItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let focus: String
    }

    private let items: [TypeItem] = [
        .init(title: "Fuerza", subtitle: "Bajas reps · descansos largos", icon: "bolt.fill", focus: "5x5 / 3x5 / RPE"),
        .init(title: "Hipertrofia", subtitle: "Volumen · técnica · congestión", icon: "flame.fill", focus: "8–15 reps / tempo"),
        .init(title: "Powerbuilding", subtitle: "Fuerza + hipertrofia", icon: "trophy.fill", focus: "Top sets + accesorios"),
        .init(title: "Full Body", subtitle: "Todo el cuerpo en una sesión", icon: "figure.strengthtraining.traditional", focus: "Eficiencia semanal"),
        .init(title: "Pierna", subtitle: "Cuádriceps · glúteo · femoral", icon: "figure.walk", focus: "Sentadilla / bisagra"),
        .init(title: "Torso", subtitle: "Pecho · espalda · hombro", icon: "figure.arms.open", focus: "Empuje / tirón")
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                SportHeroCard(
                    title: "Elige un enfoque",
                    subtitle: "El sistema te propone estructura de sets y descansos",
                    icon: "slider.horizontal.3",
                    accent: accent
                )

                LazyVStack(spacing: 12) {
                    ForEach(items) { it in
                        NavigationLink {
                            RutinaDetalleView(title: "Plantilla · \(it.title)")
                        } label: {
                            TypeCard(item: it, accent: accent)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Tipos de gimnasio")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }
}

private struct TypeCard: View {
    let item: GimnasioTipoView.TypeItem
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

            Text(item.focus)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
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

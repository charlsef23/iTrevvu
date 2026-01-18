import SwiftUI

struct CustomRoutinesCard: View {

    private let accent = TrainingBrand.custom

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(accent))

                    Image(systemName: "wand.and.stars")
                        .foregroundStyle(accent)
                        .font(.headline.weight(.bold))
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Rutinas personalizadas")
                        .font(.headline.bold())

                    Text("Ejercicios, series, descansos y notas")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                NavigationLink { CrearRutinaView() } label: {
                    Label("Nueva rutina", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(accent)

                NavigationLink { MisRutinasView() } label: {
                    Label("Mis rutinas", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(accent)
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 7, y: 4)
    }
}

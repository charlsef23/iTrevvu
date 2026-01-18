import SwiftUI

struct CustomRoutinesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.custom.opacity(0.14))

                    Image(systemName: "wand.and.stars")
                        .foregroundStyle(TrainingBrand.custom)
                        .font(.headline.weight(.bold))
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Crea tu rutina")
                        .font(.headline.bold())

                    Text("Personaliza ejercicios, series, descansos y notas")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                NavigationLink {
                    CrearRutinaView()
                } label: {
                    Label("Nueva rutina", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(TrainingBrand.custom)

                NavigationLink {
                    MisRutinasView()
                } label: {
                    Label("Mis rutinas", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(TrainingBrand.custom)
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(Color.gray.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }
}

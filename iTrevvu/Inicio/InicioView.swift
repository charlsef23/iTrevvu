import SwiftUI

struct InicioView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Resumen rápido
                    HStack(spacing: 16) {
                        SummaryCard(title: "Entrenos", value: "2", icon: "dumbbell.fill")
                        SummaryCard(title: "Calorías", value: "1.850", icon: "flame.fill")
                        SummaryCard(title: "Pasos", value: "8.432", icon: "figure.walk")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Actividad reciente")
                            .font(.title3.bold())

                        ForEach(0..<3) { _ in
                            ActivityCard()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Inicio")
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.red)
            Text(value)
                .font(.headline.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

private struct ActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🏋️ Entrenamiento de fuerza")
                .font(.headline)
            Text("45 min · Pecho & tríceps")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

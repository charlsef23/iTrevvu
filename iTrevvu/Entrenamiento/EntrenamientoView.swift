import SwiftUI

struct EntrenamientoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    Button {
                        // iniciar entrenamiento
                    } label: {
                        Label("Iniciar entrenamiento",
                              systemImage: "play.fill")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.red)
                            .cornerRadius(18)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rutinas")
                            .font(.title3.bold())

                        ForEach(0..<3) { _ in
                            WorkoutCard()
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Historial")
                            .font(.title3.bold())

                        ForEach(0..<2) { _ in
                            WorkoutHistoryRow()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Entrenamiento")
        }
    }
}

private struct WorkoutCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Fuerza - Parte superior")
                .font(.headline)
            Text("6 ejercicios · 45 min")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

private struct WorkoutHistoryRow: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Entrenamiento de fuerza")
                Text("Ayer · 42 min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}

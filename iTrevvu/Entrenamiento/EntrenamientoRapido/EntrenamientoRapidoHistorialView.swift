import SwiftUI

struct EntrenamientoRapidoHistorialView: View {

    @StateObject private var store = QuickWorkoutStore(client: SupabaseManager.shared.client)
    @State private var sessions: [QuickWorkoutSession] = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(sessions) { s in
                    HistCard(session: s)
                }
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard let uid = SupabaseManager.shared.currentUserId else { return }
            sessions = await store.loadSessions(autorId: uid)
        }
    }
}

private struct HistCard: View {
    let session: QuickWorkoutSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sesión rápida")
                .font(.headline.bold())

            Text("Duración: \(format(session.duracion_segundos))")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let c = session.calorias {
                Text("Calorías: \(c) kcal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let d = session.distancia_m {
                Text("Distancia: \(Int(d)) m")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

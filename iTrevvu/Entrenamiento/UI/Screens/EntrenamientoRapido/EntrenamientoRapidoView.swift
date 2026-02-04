import SwiftUI

struct EntrenamientoRapidoView: View {

    @StateObject private var store = QuickWorkoutStore(client: SupabaseManager.shared.client)

    @State private var go = false
    @State private var selectedType: QuickWorkoutType?
    @State private var startedSession: QuickWorkoutSession?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                header

                LazyVStack(spacing: 10) {
                    if store.isLoading {
                        ProgressView().padding(.top, 20)
                    } else if let msg = store.errorMessage {
                        Text(msg).foregroundStyle(.secondary).padding(.top, 20)
                    } else {
                        ForEach(store.types) { t in
                            Button {
                                Task {
                                    // ✅ necesitas tu autor_id (perfil.id). Si lo tienes en sesión, úsalo aquí.
                                    // Aquí asumo que auth.uid() == perfil.id (como en tu esquema).
                                    guard let uid = SupabaseManager.shared.currentUserId else { return }
                                    let autor = uid
                                    let s = await store.startSession(type: t, autorId: autor)
                                    self.selectedType = t
                                    self.startedSession = s
                                    self.go = (s != nil)
                                }
                            } label: {
                                QuickWorkoutRow(type: t)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Entrenamiento")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $go) {
            if let t = selectedType, let s = startedSession {
                EntrenandoRapidoView(type: t, session: s, store: store)
            } else {
                Text("Cargando…")
            }
        }
        .task { await store.loadTypes() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Rápido")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Elige un entreno")
                .font(.title.bold())
            Text("Sin complicaciones. Empieza y listo.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }
}

private struct QuickWorkoutRow: View {
    let type: QuickWorkoutType

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: type.color).opacity(0.18))
                Image(systemName: type.icono)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color(hex: type.color))
            }
            .frame(width: 52, height: 52)

            Text(type.nombre)
                .font(.headline.weight(.semibold))

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }
}

// MARK: - Color HEX helper

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

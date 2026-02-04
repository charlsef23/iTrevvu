import SwiftUI

struct EntrenamientoRapidoView: View {

    @StateObject private var store = QuickWorkoutStore(client: SupabaseManager.shared.client)

    @State private var go = false
    @State private var selectedType: QuickWorkoutType?
    @State private var startedSession: QuickWorkoutSession?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {

                if store.isLoading {
                    page {
                        ProgressView()
                            .scaleEffect(1.1)
                    }
                } else if let msg = store.errorMessage {
                    page {
                        Text(msg)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                } else {
                    ForEach(store.types) { t in
                        page {
                            Button {
                                Task {
                                    guard let uid = SupabaseManager.shared.currentUserId else { return }
                                    let s = await store.startSession(type: t, autorId: uid)
                                    selectedType = t
                                    startedSession = s
                                    go = (s != nil)
                                }
                            } label: {
                                // ✅ La tarjeta SIEMPRE en la misma posición
                                QuickWorkoutFullCard(type: t, height: pageCardHeight)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .scrollTargetLayout() // ✅ necesario para snap
        }
        .scrollTargetBehavior(.paging) // ✅ 1 página por “pantalla”
        .scrollBounceBehavior(.basedOnSize) // opcional (iOS 17) evita rebotes raros
        .background(TrainingBrand.bg)
        .toolbar(.hidden, for: .navigationBar) // ✅ oculta de verdad (no cambia insets)
        .navigationDestination(isPresented: $go) {
            if let t = selectedType, let s = startedSession {
                EntrenandoRapidoView(type: t, session: s, store: store)
            } else {
                Text("Cargando…")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .task { await store.loadTypes() }
    }

    // MARK: - Layout fijo

    /// Altura de la tarjeta (constante visual). Ajusta 0.84–0.88 si quieres más/menos.
    private var pageCardHeight: CGFloat {
        UIScreen.main.bounds.height * 0.86
    }

    /// ✅ 1 “page” = 1 pantalla SIEMPRE. Top-aligned para estilo Apple Fitness.
    @ViewBuilder
    private func page<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .top) {
            content()
                .padding(.top, 14)       // posición fija desde arriba
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical) // ✅ clava el tamaño de página
        .contentShape(Rectangle())
    }
}

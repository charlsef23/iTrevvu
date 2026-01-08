import SwiftUI

struct PerfilView: View {
    @EnvironmentObject private var auth: AuthService

    private enum Brand {
        static let red = Color.red
        static let bg = Color(.systemBackground)
        static let card = Color(.secondarySystemBackground)
        static let redShadow = Color.red.opacity(0.10)
        static let corner: CGFloat = 20
    }

    // Placeholder (luego conectas a Supabase)
    private let username = "usuario_fit"
    private let fullName = "Carlos"
    private let bio = "Amante del fitness y la vida sana 💪"
    private let entrenos = "120"
    private let seguidores = "1.2K"
    private let siguiendo = "180"

    @State private var showSignOutConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    PerfilHeaderView(
                        username: username,
                        fullName: fullName,
                        bio: bio
                    )

                    // Actions
                    HStack(spacing: 12) {
                        NavigationLink {
                            EditarPerfilPlaceholderView()
                        } label: {
                            Label("Editar", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Brand.red)

                        ShareLink(item: "Mira mi perfil en iTrevvu: @\(username)") {
                            Label("Compartir", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(Brand.red)
                    }

                    PerfilStatsView(stats: [
                        .init(title: "Entrenos", value: entrenos, action: { }),
                        .init(title: "Seguidores", value: seguidores, action: { }),
                        .init(title: "Siguiendo", value: siguiendo, action: { })
                    ])

                    PerfilQuickGridView(items: [
                        .init(title: "Mis posts", systemImage: "square.grid.2x2"),
                        .init(title: "Logros", systemImage: "trophy"),
                        .init(title: "Guardados", systemImage: "bookmark"),
                        .init(title: "Ajustes", systemImage: "gearshape")
                    ])

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(Brand.bg)
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AjustesView(onSignOutTapped: { showSignOutConfirm = true })
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.headline)
                            .foregroundStyle(Brand.red)
                    }
                }
            }
            .confirmationDialog(
                "¿Seguro que quieres cerrar sesión?",
                isPresented: $showSignOutConfirm,
                titleVisibility: .visible
            ) {
                Button("Cerrar sesión", role: .destructive) {
                    Task { await auth.signOut() }
                }
                Button("Cancelar", role: .cancel) { }
            }
            .tint(Brand.red)
        }
    }
}

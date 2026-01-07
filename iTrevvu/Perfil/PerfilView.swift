import SwiftUI

struct PerfilView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)

                Text("usuario_fit")
                    .font(.title.bold())

                Text("Amante del fitness y la vida sana 💪")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    ProfileStat(title: "Entrenos", value: "120")
                    ProfileStat(title: "Seguidores", value: "1.2K")
                    ProfileStat(title: "Siguiendo", value: "180")
                }

                Spacer()

                Button("Cerrar sesión") {
                    Task { await auth.signOut() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Perfil")
        }
    }
}

private struct ProfileStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.headline.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

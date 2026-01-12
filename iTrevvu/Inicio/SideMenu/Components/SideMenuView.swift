import SwiftUI

struct SideMenuView: View {
    let onClose: () -> Void

    // Navegación “push”
    @Binding var goToDM: Bool
    @Binding var goToNotifs: Bool
    @Binding var goToBuscar: Bool
    @Binding var goToPerfil: Bool
    @Binding var goToAjustes: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            SideMenuHeader(username: "usuario_fit", displayName: "Carlos")

            SideMenuRow(title: "Mensajes", systemImage: "message") {
                onClose()
                goToDM = true
            }

            SideMenuRow(title: "Notificaciones", systemImage: "heart") {
                onClose()
                goToNotifs = true
            }

            SideMenuRow(title: "Buscar", systemImage: "magnifyingglass") {
                onClose()
                goToBuscar = true
            }

            SideMenuRow(title: "Perfil", systemImage: "person") {
                onClose()
                goToPerfil = true
            }

            Spacer()

            SideMenuRow(title: "Ajustes", systemImage: "gearshape") {
                onClose()
                goToAjustes = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }
}

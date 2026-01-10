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

            SideMenuRow(title: "Mensajes", systemImage: "paperplane") {
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

            SideMenuRow(title: "Ajustes", systemImage: "gearshape") {
                onClose()
                goToAjustes = true
            }

            Spacer()

            SideMenuRow(title: "Cerrar menú", systemImage: "xmark") {
                onClose()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }
}

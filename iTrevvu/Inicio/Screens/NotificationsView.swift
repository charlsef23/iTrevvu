import SwiftUI

struct NotificationsView: View {
    var body: some View {
        List {
            Text("Notificaciones estilo Instagram (pendiente)")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
    }
}

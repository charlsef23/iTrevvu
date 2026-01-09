import SwiftUI

struct NewMessageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""

    var body: some View {
        List {
            Section {
                Text("Nuevo mensaje (pendiente)")
                    .foregroundStyle(.secondary)
                Text("Aquí buscarás usuarios y crearás un chat.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Nuevo")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Buscar usuario…")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cerrar") { dismiss() }
            }
        }
        .tint(DMBrand.red)
    }
}

import SwiftUI

struct HistorialDetalleView: View {
    let title: String
    var body: some View {
        Text("Detalle del historial: \(title) (pendiente)")
            .navigationTitle("Historial")
    }
}

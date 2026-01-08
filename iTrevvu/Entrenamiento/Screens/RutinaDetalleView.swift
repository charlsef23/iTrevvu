import SwiftUI

struct RutinaDetalleView: View {
    let title: String
    var body: some View {
        Text("Detalle de rutina: \(title) (pendiente)")
            .navigationTitle("Rutina")
    }
}

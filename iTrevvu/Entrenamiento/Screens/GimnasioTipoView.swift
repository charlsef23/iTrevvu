import SwiftUI

struct GimnasioTipoView: View {
    let title: String
    var body: some View {
        Text("Pantalla de \(title) (pendiente)")
            .navigationTitle(title)
    }
}

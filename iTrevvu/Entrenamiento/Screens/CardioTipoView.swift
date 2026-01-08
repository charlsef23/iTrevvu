import SwiftUI

struct CardioTipoView: View {
    let title: String
    var body: some View {
        Text("Pantalla de \(title) (pendiente)")
            .navigationTitle(title)
    }
}

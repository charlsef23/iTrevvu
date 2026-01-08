import SwiftUI

struct EjercicioStatsDetalleView: View {
    let title: String
    var body: some View {
        Text("Gráficas y PRs de \(title) (pendiente)")
            .navigationTitle(title)
    }
}

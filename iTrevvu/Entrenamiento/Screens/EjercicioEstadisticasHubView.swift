import SwiftUI

struct EjercicioEstadisticasHubView: View {
    var body: some View {
        List {
            NavigationLink("Press banca", destination: EjercicioStatsDetalleView(title: "Press banca"))
            NavigationLink("Sentadilla", destination: EjercicioStatsDetalleView(title: "Sentadilla"))
            NavigationLink("Peso muerto", destination: EjercicioStatsDetalleView(title: "Peso muerto"))
            NavigationLink("Carrera", destination: EjercicioStatsDetalleView(title: "Carrera"))
        }
        .navigationTitle("Estadísticas")
    }
}


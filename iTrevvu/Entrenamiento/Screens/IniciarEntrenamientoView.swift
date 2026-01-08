import SwiftUI

struct IniciarEntrenamientoView: View {
    var body: some View {
        List {
            NavigationLink("Gimnasio", destination: GimnasioHubView())
            NavigationLink("Cardio", destination: CardioHubView())
            NavigationLink("Movilidad", destination: MovilidadView())
        }
        .navigationTitle("Iniciar")
    }
}

import SwiftUI

struct CardioHubView: View {
    var body: some View {
        List {
            NavigationLink("Correr", destination: CardioTipoView(title: "Correr"))
            NavigationLink("Bici", destination: CardioTipoView(title: "Bici"))
            NavigationLink("HIIT", destination: CardioTipoView(title: "HIIT"))
            NavigationLink("Intervalos", destination: CardioTipoView(title: "Intervalos"))
        }
        .navigationTitle("Cardio")
    }
}

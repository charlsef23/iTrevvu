import SwiftUI

struct GimnasioHubView: View {
    var body: some View {
        List {
            NavigationLink("Fuerza", destination: GimnasioTipoView(title: "Fuerza"))
            NavigationLink("Hipertrofia", destination: GimnasioTipoView(title: "Hipertrofia"))
            NavigationLink("Full Body", destination: GimnasioTipoView(title: "Full Body"))
            NavigationLink("Push / Pull / Legs", destination: GimnasioTipoView(title: "PPL"))
        }
        .navigationTitle("Gimnasio")
    }
}

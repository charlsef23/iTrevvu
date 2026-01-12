import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            InicioView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            BuscarView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }
            
            EntrenamientoView()
                .tabItem {
                    Label("Fitness", systemImage: "figure.run")
                }

            NutricionView()
                .tabItem {
                    Label("Nutrición", systemImage: "chart.bar.doc.horizontal")
                }

            DirectMessagesView()
                .tabItem {
                    Label("Mensajes", systemImage: "message.fill")
                }
        }
        .tint(.red)
    }
}

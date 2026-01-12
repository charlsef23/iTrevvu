import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            InicioView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            EntrenamientoView()
                .tabItem {
                    Label("Fitness", systemImage: "figure.run")
                }

            NutricionView()
                .tabItem {
                    Label("Nutrición", systemImage: "chart.bar.doc.horizontal")
                }
            
            BuscarView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }

            DirectMessagesView()
                .tabItem {
                    Label("Mensajes", systemImage: "paperplane")
                }
        }
        .tint(.red)
    }
}

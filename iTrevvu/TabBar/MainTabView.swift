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

            PerfilView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
        .tint(.red)
    }
}

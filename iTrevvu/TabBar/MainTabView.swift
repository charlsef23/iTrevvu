import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            InicioView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }

            NutricionView()
                .tabItem {
                    Label("Nutrición", systemImage: "leaf.fill")
                }

            EntrenamientoView()
                .tabItem {
                    Label("Fitness", systemImage: "figure.run")
                }

            PerfilView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
    }
}

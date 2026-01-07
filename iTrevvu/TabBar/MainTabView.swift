import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            InicioView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }

            NutriciónView()
                .tabItem {
                    Label("Nutrición", systemImage: "leaf.fill")
                }

            EntrenamientoView()
                .tabItem {
                    Label("Entrenar", systemImage: "dumbbell.fill")
                }

            PerfilView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
    }
}

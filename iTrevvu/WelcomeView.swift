import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // Logo / Título (temporal)
                Text("iTrevvu")
                    .font(.system(size: 40, weight: .bold))

                Text("La red social para deportistas.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                NavigationLink {
                    RegisterView()
                } label: {
                    Text("Crear cuenta")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    LoginView()
                } label: {
                    Text("Iniciar sesión")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

            }
            .padding()
        }
    }
}

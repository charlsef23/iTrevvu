import SwiftUI

private enum Brand {
    static let red = Color.red
    static let bg = Color(.systemBackground)
    static let fieldBG = Color(.secondarySystemBackground)
    static let corner: CGFloat = 28 // pill
    static let shadow = Color.red.opacity(0.12)
}

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con gradiente suave que respeta modo oscuro
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 28) {
                    Spacer(minLength: 12)
                    
                    // Hero: solo imagen sin contenedor ni fondo
                    Image("IconoSinFondo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 340)
                        .padding(.top, 6)
                        .accessibilityHidden(true)
                    
                    Spacer()
                    
                    // Acciones (sin tarjeta blanca de fondo)
                    VStack(spacing: 14) {
                        NavigationLink {
                            RegisterView()
                        } label: {
                            AuthPrimaryButtonLabel(title: "Crear cuenta")
                        }
                        .buttonStyle(.plain)
                        .shadow(color: Brand.shadow, radius: 12, y: 6)
                        
                        NavigationLink {
                            LoginView()
                        } label: {
                            AuthSecondaryButtonLabel(title: "Iniciar sesión")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 4)
                    
                    Text("Al continuar, aceptas nuestros Términos y Política de privacidad.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 22)
            }
        }
    }
}

private struct AuthPrimaryButtonLabel: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline.weight(.bold))
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .fill(Brand.red)
            )
            .overlay(
                // Borde/realce sutil para dar definición
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
            .accessibilityAddTraits(.isButton)
    }
}

private struct AuthSecondaryButtonLabel: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .foregroundColor(Brand.red)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                // Fondo muy sutil para que no sea “blanco” ni un bloque
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .stroke(Brand.red.opacity(0.55), lineWidth: 1.2)
            )
            .contentShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
            .accessibilityAddTraits(.isButton)
    }
}

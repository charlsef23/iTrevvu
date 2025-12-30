import SwiftUI

private enum Brand {
    static let red = Color.red
    static let bg = Color.white
    static let fieldBG = Color(.systemGray6)
    static let corner: CGFloat = 16
    static let shadow = Color.red.opacity(0.10)
}

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Brand.bg.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer(minLength: 12)
                    
                    // Hero
                    VStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Brand.fieldBG)
                                .frame(width: 110, height: 110)
                                .shadow(color: Brand.shadow, radius: 18, y: 8)
                            
                            Image("LogoApp")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 84, height: 84)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        
                        Text("iTrevvu")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundColor(Brand.red)
                        
                        Text("Entrena. Comparte. Mejora.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // Card de acciones
                    VStack(spacing: 14) {
                        NavigationLink {
                            RegisterView()
                        } label: {
                            AuthPrimaryButtonLabel(title: "Crear cuenta")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .shadow(color: Brand.shadow, radius: 10, y: 4)
                        
                        NavigationLink {
                            LoginView()
                        } label: {
                            AuthSecondaryButtonLabel(title: "Iniciar sesión")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Brand.bg)
                            .shadow(color: Brand.shadow, radius: 14, y: 6)
                    )
                    
                    Text("Al continuar, aceptas nuestros Términos y Política de privacidad.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
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
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .fill(Brand.red)
            )
            .contentShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
    }
}

private struct AuthSecondaryButtonLabel: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundColor(Brand.red)
            .background(
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .stroke(Brand.red, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: Brand.corner, style: .continuous).fill(.white)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
    }
}

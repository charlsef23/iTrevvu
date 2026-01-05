import SwiftUI

private enum Brand {
    static let red = Color.red
    static let bg = Color(.systemBackground)
    static let fieldBG = Color(.secondarySystemBackground)
    static let corner: CGFloat = 28 // pill para consistencia con WelcomeView
    static let shadow = Color.red.opacity(0.12)
}

struct LoginView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ZStack {
            // Fondo con gradiente suave como en WelcomeView
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Hero: imagen sin contenedor ni subtítulo
                    Image("IconoSinFondo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                        .padding(.top, 12)
                        .accessibilityHidden(true)
                    
                    // Campos (sin tarjeta blanca)
                    VStack(spacing: 12) {
                        AuthTextField(
                            text: $email,
                            placeholder: "Email",
                            systemImage: "envelope",
                            contentType: .emailAddress,
                            keyboard: .emailAddress
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        
                        AuthSecureField(
                            text: $password,
                            placeholder: "Contraseña",
                            systemImage: "lock"
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { Task { await login() } }
                    }
                    .shadow(color: Brand.shadow.opacity(0.6), radius: 6, y: 3)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(Brand.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }
                    
                    // Botón primario con el mismo estilo que WelcomeView (sin iconos ni animaciones)
                    Button {
                        Task { await login() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 56)
                        } else {
                            AuthPrimaryButtonLabel(title: "Entrar")
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading || !isValid)
                    .shadow(color: Brand.shadow, radius: 12, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focusedField = .email }
    }

    private var isValid: Bool {
        email.contains("@") && password.count >= 6
    }

    private func login() async {
        guard isValid else {
            errorMessage = "Revisa el email y la contraseña (mínimo 6 caracteres)."
            return
        }

        isLoading = true
        errorMessage = nil
        focusedField = nil

        do {
            try await auth.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                  password: password)
        } catch {
            errorMessage = humanize(error)
        }

        isLoading = false
    }

    private func humanize(_ error: Error) -> String {
        let msg = error.localizedDescription.lowercased()
        if msg.contains("invalid") || msg.contains("credentials") {
            return "Email o contraseña incorrectos."
        }
        if msg.contains("network") || msg.contains("offline") {
            return "No hay conexión. Inténtalo de nuevo."
        }
        return "Error al iniciar sesión. Inténtalo de nuevo."
    }
}

// MARK: - Componentes de campos con estilo actualizado

private struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    var contentType: UITextContentType? = nil
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(Brand.red)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(contentType)
                .keyboardType(keyboard)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Brand.corner)
                .stroke(Brand.red.opacity(0.55), lineWidth: 1.2)
                .background(
                    RoundedRectangle(cornerRadius: Brand.corner).fill(Brand.fieldBG)
                )
        )
    }
}

private struct AuthSecureField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(Brand.red)
            SecureField(placeholder, text: $text)
                .textContentType(.password)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Brand.corner)
                .stroke(Brand.red.opacity(0.55), lineWidth: 1.2)
                .background(
                    RoundedRectangle(cornerRadius: Brand.corner).fill(Brand.fieldBG)
                )
        )
    }
}

// MARK: - Botón primario consistente con WelcomeView (sin iconos ni animaciones)

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
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
            .accessibilityAddTraits(.isButton)
    }
}

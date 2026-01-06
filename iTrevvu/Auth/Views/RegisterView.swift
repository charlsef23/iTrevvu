import SwiftUI

private enum Brand {
    static let red = Color.red
    static let bg = Color(.systemBackground)
    static let fieldBG = Color(.secondarySystemBackground)
    static let corner: CGFloat = 28 // pill para consistencia con WelcomeView
    static let shadow = Color.red.opacity(0.12)
}

struct RegisterView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    enum Field { case username, email, password, confirmPassword }

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
                            text: $username,
                            placeholder: "Username",
                            systemImage: "person",
                            contentType: .username
                        )
                        .focused($focusedField, equals: .username)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                        
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
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirmPassword }
                        
                        AuthSecureField(
                            text: $confirmPassword,
                            placeholder: "Repetir contraseña",
                            systemImage: "lock.rotation"
                        )
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.go)
                        .onSubmit { Task { await register() } }
                    }
                    .shadow(color: Brand.shadow.opacity(0.6), radius: 6, y: 3)
                    
                    requirements
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(Brand.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }
                    
                    Button {
                        Task { await register() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 56)
                        } else {
                            AuthPrimaryButtonLabel(title: "Crear cuenta")
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading || !formValid)
                    .shadow(color: Brand.shadow, radius: 12, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focusedField = .username }
    }

    private var requirements: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Requisitos")
                .font(.subheadline.bold())
                .foregroundColor(Brand.red)
            Text("• Username: 3–20 caracteres, sin espacios")
            Text("• Contraseña: mínimo 6 caracteres")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 2)
    }

    private var cleanUsername: String {
        username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private var formValid: Bool {
        let u = cleanUsername
        let usernameOk = u.count >= 3 && u.count <= 20 && !u.contains(" ")
        let emailOk = email.contains("@")
        let passOk = password.count >= 6 && password == confirmPassword
        return usernameOk && emailOk && passOk
    }

    private func register() async {
        guard formValid else {
            errorMessage = "Revisa los datos antes de continuar."
            return
        }

        isLoading = true
        errorMessage = nil
        focusedField = nil

        do {
            try await auth.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                username: cleanUsername
            )
        } catch {
            errorMessage = humanize(error)
        }

        isLoading = false
    }

    private func humanize(_ error: Error) -> String {
        let msg = error.localizedDescription.lowercased()

        if msg.contains("already") || msg.contains("exists") {
            return "Ese email o username ya está en uso."
        }
        if msg.contains("password") && msg.contains("weak") {
            return "Contraseña demasiado débil. Usa una más fuerte."
        }
        if msg.contains("network") || msg.contains("offline") {
            return "No hay conexión. Inténtalo de nuevo."
        }
        return "Error al crear la cuenta. Inténtalo de nuevo."
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
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(Brand.red)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(.newPassword)
                } else {
                    TextField(placeholder, text: $text)
                        .textContentType(.newPassword)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(.secondary)
                    .accessibilityLabel(isSecure ? "Mostrar contraseña" : "Ocultar contraseña")
            }
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

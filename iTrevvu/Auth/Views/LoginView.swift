import SwiftUI

private enum Brand {
    static let red = Color.red
    static let bg = Color.white
    static let fieldBG = Color(.systemGray6)
    static let corner: CGFloat = 16
    static let shadow = Color.red.opacity(0.10)
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
            Brand.bg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 22) {
                    // Hero
                    AuthHero(title: "Iniciar sesión", subtitle: "Accede a tu cuenta para seguir entrenando.")
                    
                    // Card
                    VStack(spacing: 16) {
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
                        .shadow(color: Brand.shadow, radius: 6, y: 3)
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(Brand.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity)
                        }
                        
                        Button {
                            Task { await login() }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 54)
                            } else {
                                AuthPrimaryButtonLabel(title: "Entrar")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isLoading || !isValid)
                        .shadow(color: Brand.shadow, radius: 10, y: 4)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Brand.bg)
                            .shadow(color: Brand.shadow, radius: 14, y: 6)
                    )
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

private struct AuthHero: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Brand.fieldBG)
                    .frame(width: 94, height: 94)
                    .shadow(color: Brand.shadow, radius: 16, y: 7)
                
                Image("LogoApp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title.bold())
                    .foregroundColor(Brand.red)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

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
                .stroke(Brand.red.opacity(0.6), lineWidth: 1.2)
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
                .stroke(Brand.red.opacity(0.6), lineWidth: 1.2)
                .background(
                    RoundedRectangle(cornerRadius: Brand.corner).fill(Brand.fieldBG)
                )
        )
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

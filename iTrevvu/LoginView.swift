import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Iniciar sesión")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Contraseña", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task { await mockLogin() }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Entrar")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            Spacer()
        }
        .padding()
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func mockLogin() async {
        isLoading = true
        errorMessage = nil
        try? await Task.sleep(nanoseconds: 700_000_000)
        isLoading = false

        guard email.contains("@"), password.count >= 6 else {
            errorMessage = "Email o contraseña inválidos."
            return
        }

        // Luego aquí conectamos Supabase Auth
        errorMessage = "✅ Login OK (mock)"
    }
}

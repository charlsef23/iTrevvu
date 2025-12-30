import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Crear cuenta")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Contraseña", text: $password)
                .textFieldStyle(.roundedBorder)

            SecureField("Repetir contraseña", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task { await mockRegister() }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Crear cuenta")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || !formValid)

            Spacer()
        }
        .padding()
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formValid: Bool {
        !username.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }

    private func mockRegister() async {
        isLoading = true
        errorMessage = nil
        try? await Task.sleep(nanoseconds: 900_000_000)
        isLoading = false

        guard formValid else {
            errorMessage = "Revisa los datos. Password mínimo 6 y que coincidan."
            return
        }

        // Luego aquí conectamos Supabase Auth + crear perfil
        errorMessage = "✅ Cuenta creada (mock)"
    }
}

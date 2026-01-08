import SwiftUI

struct EditarPerfilPlaceholderView: View {
    private enum Brand { static let red = Color.red }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Brand.red.opacity(0.12))
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Brand.red)
            }
            .frame(width: 64, height: 64)

            Text("Editar Perfil (pendiente)")
                .font(.headline)

            Text("Aquí conectaremos tu perfil real desde Supabase.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Editar perfil")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Brand.red)
    }
}

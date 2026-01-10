import SwiftUI

struct HomeTopBar: View {
    let onAvatarTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onAvatarTap) {
                Circle()
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Circle().strokeBorder(FeedBrand.red.opacity(0.25), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Text("iTrevvu")
                .font(.headline.bold())
                .foregroundStyle(.primary)

            Spacer()

            // Dejo un “espaciador” para centrar título como Twitter.
            // Si quieres un botón extra a la derecha (ej: + post), lo añadimos aquí.
            Color.clear.frame(width: 34, height: 34)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

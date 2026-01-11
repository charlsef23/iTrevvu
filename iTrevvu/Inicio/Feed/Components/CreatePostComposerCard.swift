import SwiftUI

struct CreatePostComposerCard: View {
    let onTextPost: () -> Void
    let onMediaPost: () -> Void
    let onWorkoutPost: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(name: "Carlos", size: 38)

                Text("¿Qué quieres compartir hoy?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            HStack(spacing: 10) {
                ComposerButton(title: "Texto", systemImage: "text.quote", tint: FeedBrand.red, action: onTextPost)
                ComposerButton(title: "Foto/Vídeo", systemImage: "photo.on.rectangle", tint: FeedBrand.red, action: onMediaPost)
                ComposerButton(title: "Entreno", systemImage: "dumbbell.fill", tint: FeedBrand.red, action: onWorkoutPost)
            }
        }
        .padding(14)
        .background(FeedBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: FeedBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: FeedBrand.corner, style: .continuous)
                .strokeBorder(FeedBrand.red.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct ComposerButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(tint)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

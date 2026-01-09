import SwiftUI

struct PostActionsRow: View {
    @Binding var isLiked: Bool
    let likes: Int
    let comments: Int

    var body: some View {
        HStack(spacing: 16) {
            Button {
                isLiked.toggle()
            } label: {
                Label(isLiked ? "Me gusta" : "Me gusta", systemImage: isLiked ? "heart.fill" : "heart")
                    .labelStyle(.iconOnly)
                    .font(.headline)
                    .foregroundStyle(isLiked ? Color.red : Color.primary)
            }
            .buttonStyle(.plain)

            Label("\(likes)", systemImage: "heart")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Label("\(comments)", systemImage: "message")
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: "bookmark")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 6)
    }
}

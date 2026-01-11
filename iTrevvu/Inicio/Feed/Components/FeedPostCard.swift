import SwiftUI

struct FeedPostCard: View {
    @Binding var post: FeedPost
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header
            HStack(spacing: 12) {
                AvatarView(name: post.author.displayName, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author.displayName)
                        .font(.subheadline.weight(.semibold))
                    Text("@\(post.author.username) · \(FeedTimeFormatter.relative(post.createdAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
            }

            // Content
            Group {
                switch post.content {
                case .text(let text):
                    TextPostView(text: text)

                case .media(let text, let items):
                    MediaPostView(text: text, items: items)

                case .workout(let text, let workout):
                    WorkoutPostView(text: text, workout: workout)
                }
            }
            .onTapGesture { onOpen() }

            // Actions
            PostActionsRow(isLiked: $post.isLiked, likes: post.likes, comments: post.comments)
        }
        .padding(14)
        .background(FeedBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: FeedBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: FeedBrand.corner, style: .continuous)
                .strokeBorder(FeedBrand.red.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: FeedBrand.shadow, radius: 10, y: 6)
    }
}

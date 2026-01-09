import SwiftUI

struct StoriesRow: View {
    let stories: [StoryItem]
    let onTapStory: (StoryItem) -> Void

    /// Padding lateral “real” del contenido de stories.
    /// Pon 16 para alinearlo con tu layout general, pero SIN que parezca que hay borde.
    var sideInset: CGFloat = 16

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(stories) { story in
                    StoryBubble(story: story)
                        .onTapGesture { onTapStory(story) }
                }
            }
            // Insets internos del contenido (para que el primero/último respiren y se llegue al final)
            .padding(.horizontal, sideInset)
            .padding(.vertical, 6)
        }
    }
}

private struct StoryBubble: View {
    let story: StoryItem

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {

                // Ring (degradado si hay nueva)
                ZStack {
                    if story.hasNew {
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [FeedBrand.red, FeedBrand.red.opacity(0.55), FeedBrand.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3.5
                            )
                    } else {
                        Circle()
                            .strokeBorder(Color.gray.opacity(0.22), lineWidth: 1.5)
                    }
                }
                .frame(width: 70, height: 70)

                // Avatar interior (placeholder)
                Circle()
                    .fill(Color.gray.opacity(0.16))
                    .frame(width: 62, height: 62)
                    .overlay {
                        Text(initials(story.displayName))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }

                // “+” en tu historia
                if story.isMe {
                    ZStack {
                        Circle().fill(FeedBrand.red)
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle().strokeBorder(Color(.systemBackground), lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
                }
            }

            Text(story.isMe ? "Tu historia" : story.username)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.primary.opacity(story.isMe ? 0.9 : 0.8))
                .lineLimit(1)
                .frame(width: 74)
        }
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ").map(String.init)
        let a = parts.first?.first.map(String.init) ?? "U"
        let b = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }
}

import SwiftUI

struct MediaPostView: View {
    let text: String?
    let items: [MediaAttachment]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let text, !text.isEmpty {
                Text(text)
                    .font(.subheadline)
            }

            // Simple: enseña el primer item como “hero”
            if let first = items.first {
                MediaHero(item: first)
            }

            if items.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(items.dropFirst().enumerated()), id: \.offset) { idx, item in
                            MediaThumb(item: item)
                        }
                    }
                }
            }
        }
        .padding(.top, 6)
    }
}

private struct MediaHero: View {
    let item: MediaAttachment

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.gray.opacity(0.18))
            .frame(maxWidth: .infinity)
            .aspectRatio(item.aspectRatio, contentMode: .fit)
            .overlay(alignment: .center) {
                Label(mediaLabel(item), systemImage: mediaIcon(item))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
    }

    private func mediaIcon(_ item: MediaAttachment) -> String {
        switch item.type {
        case .image: return "photo"
        case .video: return "play.circle.fill"
        }
    }

    private func mediaLabel(_ item: MediaAttachment) -> String {
        switch item.type {
        case .image: return "Imagen"
        case .video: return "Vídeo"
        }
    }
}

private struct MediaThumb: View {
    let item: MediaAttachment

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.gray.opacity(0.16))
            .frame(width: 120, height: 90)
            .overlay {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
            }
    }

    private var icon: String {
        switch item.type {
        case .image: return "photo"
        case .video: return "play.circle"
        }
    }
}

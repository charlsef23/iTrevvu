import SwiftUI

struct MediaGridCell: View {
    let post: PublicPost

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.gray.opacity(0.16))
                .overlay {
                    // Placeholder visual
                    Image(systemName: post.kind == .clip ? "play.circle.fill" : "photo")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

            if post.kind == .clip {
                Image(systemName: "video.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(6)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

import SwiftUI

struct PostViewerView: View {
    let user: PublicUser
    let post: PublicPost

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                HStack(spacing: 10) {
                    Circle().fill(Color.gray.opacity(0.18))
                        .frame(width: 42, height: 42)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.displayName).font(.subheadline.weight(.semibold))
                        Text("@\(user.username)").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.gray.opacity(0.16))
                    .frame(height: 380)
                    .overlay {
                        if post.kind == .clip {
                            Label("Clip (pendiente reproductor)", systemImage: "play.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.subheadline.weight(.semibold))
                        } else {
                            Label("Foto (pendiente imagen real)", systemImage: "photo")
                                .foregroundStyle(.secondary)
                                .font(.subheadline.weight(.semibold))
                        }
                    }

                if let caption = post.caption, !caption.isEmpty {
                    Text(caption).font(.subheadline)
                }

                HStack(spacing: 14) {
                    Label("\(post.likes)", systemImage: "heart")
                        .foregroundStyle(.secondary)
                    Label("\(post.comments)", systemImage: "message")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .font(.caption)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .navigationTitle(post.kind == .clip ? "Clip" : "Foto")
        .navigationBarTitleDisplayMode(.inline)
        .tint(SearchBrand.red)
    }
}

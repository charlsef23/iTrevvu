import SwiftUI

struct AttachmentCard: View {
    let attachment: DMAttachment

    var body: some View {
        switch attachment {
        case .photo:
            MediaAttachmentCard(title: "Foto", systemImage: "photo")

        case .video:
            MediaAttachmentCard(title: "Vídeo", systemImage: "play.circle.fill")

        case .routine(_, let title, let subtitle):
            DomainCard(title: title, subtitle: subtitle, systemImage: "list.bullet.rectangle", tint: DMBrand.red)

        case .workout(_, let title, let subtitle, let sport):
            DomainCard(title: title, subtitle: "\(sport) · \(subtitle)", systemImage: "dumbbell.fill", tint: DMBrand.red)

        case .diet(_, let title, let subtitle):
            DomainCard(title: title, subtitle: subtitle, systemImage: "leaf.fill", tint: DMBrand.red)

        case .meal(_, let title, let subtitle):
            DomainCard(title: title, subtitle: subtitle, systemImage: "fork.knife", tint: DMBrand.red)

        case .feedPost(_, let author, let preview):
            DomainCard(title: "Post de \(author)", subtitle: preview, systemImage: "square.grid.2x2", tint: DMBrand.red)

        case .link(let urlString, let title):
            DomainCard(title: title, subtitle: urlString, systemImage: "link", tint: DMBrand.red)
        }
    }
}

private struct DomainCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.14))
                    Image(systemName: systemImage)
                        .foregroundStyle(tint)
                        .font(.subheadline.weight(.bold))
                }
                .frame(width: 34, height: 34)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()
            }

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(minWidth: 240, alignment: .leading)
    }
}

private struct MediaAttachmentCard: View {
    let title: String
    let systemImage: String

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.gray.opacity(0.18))
            .frame(width: 260, height: 170)
            .overlay {
                Label(title, systemImage: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
    }
}

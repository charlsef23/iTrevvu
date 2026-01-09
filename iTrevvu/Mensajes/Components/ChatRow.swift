import SwiftUI

struct ChatRow: View {
    let chat: DMChat
    let meId: UUID

    private var other: DMUser {
        chat.members.first(where: { $0.id != meId }) ?? chat.members.first!
    }

    var body: some View {
        HStack(spacing: 12) {
            DMAvatarView(name: other.displayName, size: 48)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(other.displayName)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(DMTimeFormatter.relative(chat.lastMessageAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text(chat.lastMessagePreview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(DMBrand.red)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}

import SwiftUI

struct MessageContentView: View {
    let content: DMMessageContent

    var body: some View {
        switch content {
        case .text(let text):
            AnyView(
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            )

        case .attachment(let attachment, let caption):
            AnyView(
                VStack(alignment: .leading, spacing: 10) {
                    AttachmentCard(attachment: attachment)

                    if let caption, !caption.isEmpty {
                        Text(caption)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            )
        }
    }
}

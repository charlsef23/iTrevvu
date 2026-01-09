import SwiftUI

struct MessageBubble: View {
    let isMe: Bool
    let timeText: String
    let state: DMSendState
    @ViewBuilder let content: () -> AnyView

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isMe { Spacer(minLength: 40) }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
                content()
                    .padding(12)
                    .background(bubbleBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                HStack(spacing: 6) {
                    Text(timeText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if isMe {
                        Text(stateLabel)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !isMe { Spacer(minLength: 40) }
        }
        .padding(.vertical, 2)
    }

    private var bubbleBackground: Color {
        isMe ? DMBrand.red.opacity(0.14) : Color(.secondarySystemBackground)
    }

    private var stateLabel: String {
        switch state {
        case .sending: return "Enviando…"
        case .sent: return "Enviado"
        case .delivered: return "Entregado"
        case .seen: return "Visto"
        }
    }
}

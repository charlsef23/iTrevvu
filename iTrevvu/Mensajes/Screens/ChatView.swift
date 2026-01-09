import SwiftUI

struct ChatView: View {
    let chat: DMChat
    let me: DMUser

    @State private var messages: [DMMessage]
    @State private var inputText: String = ""

    @State private var showAttachmentSheet = false
    @State private var pendingAttachment: DMAttachment?
    @State private var showPreviewSend = false

    init(chat: DMChat, me: DMUser) {
        self.chat = chat
        self.me = me
        _messages = State(initialValue: DMMockData.messages(chatId: chat.id))
    }

    private var other: DMUser {
        chat.members.first(where: { $0.id != me.id }) ?? chat.members.first!
    }

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 6) {
                        ForEach(messages) { msg in
                            MessageBubble(
                                isMe: msg.senderId == me.id,
                                timeText: DMTimeFormatter.time(msg.sentAt),
                                state: msg.state
                            ) {
                                AnyView(MessageContentView(content: msg.content))
                            }
                            .id(msg.id)
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.top, 12)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            MessageComposer(
                text: $inputText,
                onTapPlus: { showAttachmentSheet = true },
                onSend: { sendText() }
            )
        }
        .navigationTitle(other.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAttachmentSheet) {
            AttachmentPickerSheet(
                onPick: { attachment in
                    pendingAttachment = attachment
                    showAttachmentSheet = false
                    showPreviewSend = true
                },
                onClose: { showAttachmentSheet = false }
            )
        }
        .sheet(isPresented: $showPreviewSend) {
            if let pendingAttachment {
                NavigationStack {
                    AttachmentPreviewSendView(attachment: pendingAttachment) { caption in
                        sendAttachment(pendingAttachment, caption: caption)
                    }
                }
            }
        }
        .tint(DMBrand.red)
    }

    private func sendText() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""

        var msg = DMMessage(
            id: UUID(),
            chatId: chat.id,
            senderId: me.id,
            sentAt: .now,
            content: .text(trimmed),
            state: .sending
        )
        messages.append(msg)

        // Simula envío (luego: Supabase insert + realtime)
        simulateDelivery(for: msg.id)
    }

    private func sendAttachment(_ attachment: DMAttachment, caption: String?) {
        var msg = DMMessage(
            id: UUID(),
            chatId: chat.id,
            senderId: me.id,
            sentAt: .now,
            content: .attachment(attachment, caption: caption),
            state: .sending
        )
        messages.append(msg)
        simulateDelivery(for: msg.id)
    }

    private func simulateDelivery(for id: UUID) {
        // Cambia state con delays (demo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            updateState(id: id, to: .sent)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            updateState(id: id, to: .delivered)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            updateState(id: id, to: .seen)
        }
    }

    private func updateState(id: UUID, to newState: DMSendState) {
        guard let idx = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[idx].state = newState
    }
}

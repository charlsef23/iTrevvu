import SwiftUI

struct DirectMessagesView: View {

    private let me = DMMockData.me
    @State private var chats: [DMChat] = DMMockData.chats()
    @State private var query: String = ""
    @State private var showNewMessage = false

    private var filtered: [DMChat] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return chats }
        return chats.filter { chat in
            chat.members.contains { $0.displayName.localizedCaseInsensitiveContains(q) || $0.username.localizedCaseInsensitiveContains(q) }
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { chat in
                NavigationLink {
                    ChatView(chat: chat, me: me)
                } label: {
                    ChatRow(chat: chat, meId: me.id)
                }
            }
        }
        .navigationTitle("Mensajes")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Buscar")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewMessage = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(DMBrand.red)
                }
            }
        }
        .sheet(isPresented: $showNewMessage) {
            NavigationStack {
                NewMessageView()
            }
        }
        .tint(DMBrand.red)
    }
}

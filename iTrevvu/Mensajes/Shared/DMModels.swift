import Foundation

struct DMUser: Identifiable, Hashable {
    let id: UUID
    var username: String
    var displayName: String
}

struct DMChat: Identifiable, Hashable {
    let id: UUID
    var members: [DMUser]              // 2 (por ahora), luego grupos
    var lastMessagePreview: String
    var lastMessageAt: Date
    var unreadCount: Int
}

enum DMSendState: Hashable {
    case sending
    case sent
    case delivered
    case seen
}

enum DMAttachment: Hashable {
    // MEDIA (placeholder)
    case photo(localIdentifier: String?)
    case video(localIdentifier: String?)

    // Dominios de tu app
    case routine(id: UUID, title: String, subtitle: String)
    case workout(id: UUID, title: String, subtitle: String, sport: String)
    case diet(id: UUID, title: String, subtitle: String)
    case meal(id: UUID, title: String, subtitle: String)
    case feedPost(id: UUID, author: String, preview: String)

    // Enlace genérico (por si te sirve)
    case link(urlString: String, title: String)
}

enum DMMessageContent: Hashable {
    case text(String)
    case attachment(DMAttachment, caption: String?)
}

struct DMMessage: Identifiable, Hashable {
    let id: UUID
    var chatId: UUID
    var senderId: UUID
    var sentAt: Date
    var content: DMMessageContent
    var state: DMSendState
}

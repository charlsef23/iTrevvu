import Foundation

enum DMMockData {
    static let me = DMUser(id: UUID(), username: "usuario_fit", displayName: "Carlos")
    static let ana = DMUser(id: UUID(), username: "ana_run", displayName: "Ana")
    static let marcos = DMUser(id: UUID(), username: "marcos_gym", displayName: "Marcos")

    static func chats() -> [DMChat] {
        [
            DMChat(
                id: UUID(),
                members: [me, ana],
                lastMessagePreview: "Te paso la rutina y el entreno de hoy 💪",
                lastMessageAt: Date().addingTimeInterval(-60*15),
                unreadCount: 2
            ),
            DMChat(
                id: UUID(),
                members: [me, marcos],
                lastMessagePreview: "Buenísima esa marca en banca 🔥",
                lastMessageAt: Date().addingTimeInterval(-60*120),
                unreadCount: 0
            )
        ]
    }

    static func messages(chatId: UUID) -> [DMMessage] {
        [
            DMMessage(
                id: UUID(),
                chatId: chatId,
                senderId: ana.id,
                sentAt: Date().addingTimeInterval(-60*50),
                content: .text("Ey! ¿Me pasas tu rutina de upper?"),
                state: .seen
            ),
            DMMessage(
                id: UUID(),
                chatId: chatId,
                senderId: me.id,
                sentAt: Date().addingTimeInterval(-60*48),
                content: .attachment(.routine(id: UUID(), title: "Upper · Fuerza", subtitle: "6 ejercicios · 45 min"), caption: "Aquí la tienes 👇"),
                state: .seen
            ),
            DMMessage(
                id: UUID(),
                chatId: chatId,
                senderId: ana.id,
                sentAt: Date().addingTimeInterval(-60*40),
                content: .attachment(.workout(id: UUID(), title: "Running · Easy", subtitle: "5.2 km · 28 min", sport: "Running"), caption: "Yo hice esto hoy!"),
                state: .delivered
            ),
            DMMessage(
                id: UUID(),
                chatId: chatId,
                senderId: me.id,
                sentAt: Date().addingTimeInterval(-60*5),
                content: .text("Perfecto, mañana te cuento sensaciones 💥"),
                state: .delivered
            )
        ]
    }
}

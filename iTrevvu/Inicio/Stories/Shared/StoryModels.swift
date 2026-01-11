import Foundation

struct StoryItem: Identifiable, Hashable {
    let id: UUID
    var username: String
    var displayName: String
    var hasNew: Bool
    var isMe: Bool
}

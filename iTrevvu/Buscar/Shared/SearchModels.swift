import Foundation

struct PublicUser: Identifiable, Hashable {
    let id: UUID
    var username: String
    var displayName: String
    var bio: String
    var followers: Int
    var following: Int
    var workouts: Int
    var isFollowing: Bool
}

enum MediaKind: String, CaseIterable, Identifiable {
    case photo = "Fotos"
    case clip = "Clips"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .photo: return "photo.on.rectangle"
        case .clip: return "play.rectangle.on.rectangle"
        }
    }
}

struct PublicPost: Identifiable, Hashable {
    let id: UUID
    var authorId: UUID
    var kind: MediaKind
    var caption: String?
    var createdAt: Date
    var likes: Int
    var comments: Int
}

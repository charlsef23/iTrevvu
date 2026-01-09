import Foundation

struct FeedUser: Identifiable, Hashable {
    let id: UUID
    var username: String
    var displayName: String
}

enum SportType: String, CaseIterable, Identifiable {
    case gym = "Gimnasio"
    case running = "Running"
    case cycling = "Ciclismo"
    case swimming = "Natación"
    case football = "Fútbol"
    case basketball = "Baloncesto"
    case yoga = "Yoga"
    case hiit = "HIIT"

    var id: String { rawValue }
}

struct WorkoutSummary: Hashable {
    var sport: SportType
    var title: String
    var durationMinutes: Int
    var calories: Int?
    var mainMetric: String // ej: "Volumen 12.4K kg", "5.2 km", "420 kcal"
    var secondaryMetric: String // ej: "PRs 2", "Ritmo 5:10", etc.
}

enum MediaType: Hashable {
    case image(url: URL?)
    case video(url: URL?)
}

struct MediaAttachment: Hashable {
    var type: MediaType
    var aspectRatio: Double // 1.0 cuadrado, 4/5, 16/9...
}

enum PostContent: Hashable {
    case text(String)
    case media(text: String?, items: [MediaAttachment])
    case workout(text: String?, workout: WorkoutSummary)
}

struct FeedPost: Identifiable, Hashable {
    let id: UUID
    var author: FeedUser
    var createdAt: Date
    var content: PostContent

    // social state (demo)
    var likes: Int
    var comments: Int
    var isLiked: Bool
}

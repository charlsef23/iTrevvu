import Foundation

enum FeedMockData {
    static let me = FeedUser(id: UUID(), username: "usuario_fit", displayName: "Carlos")

    static func samplePosts() -> [FeedPost] {
        [
            FeedPost(
                id: UUID(),
                author: FeedUser(id: UUID(), username: "laura_run", displayName: "Laura"),
                createdAt: Date().addingTimeInterval(-60*18),
                content: .text("Hoy tocó día de descanso activo. 30 min caminando y estiramientos. 🔥\n\n¿Vosotros qué tal?"),
                likes: 128,
                comments: 14,
                isLiked: false
            ),
            FeedPost(
                id: UUID(),
                author: FeedUser(id: UUID(), username: "marcos_gym", displayName: "Marcos"),
                createdAt: Date().addingTimeInterval(-60*60*2),
                content: .workout(
                    text: "Upper day. Buenas sensaciones 💪",
                    workout: .init(
                        sport: .gym,
                        title: "Fuerza · Parte superior",
                        durationMinutes: 46,
                        calories: 410,
                        mainMetric: "Volumen 12.4K kg",
                        secondaryMetric: "PRs 2"
                    )
                ),
                likes: 342,
                comments: 28,
                isLiked: true
            ),
            FeedPost(
                id: UUID(),
                author: FeedUser(id: UUID(), username: "pablo", displayName: "Pablo"),
                createdAt: Date().addingTimeInterval(-60*60*6),
                content: .media(
                    text: "Atardecer brutal en la ruta 🚴‍♂️",
                    items: [
                        MediaAttachment(type: .image(url: nil), aspectRatio: 4.0/5.0),
                        MediaAttachment(type: .image(url: nil), aspectRatio: 1.0)
                    ]
                ),
                likes: 89,
                comments: 9,
                isLiked: false
            ),
            FeedPost(
                id: UUID(),
                author: FeedUser(id: UUID(), username: "maria", displayName: "María"),
                createdAt: Date().addingTimeInterval(-60*60*24),
                content: .workout(
                    text: "Rodaje suave para sumar km ✅",
                    workout: .init(
                        sport: .running,
                        title: "Running · Easy",
                        durationMinutes: 28,
                        calories: 260,
                        mainMetric: "5.2 km",
                        secondaryMetric: "Ritmo 5:20/km"
                    )
                ),
                likes: 210,
                comments: 21,
                isLiked: false
            )
        ]
    }
}

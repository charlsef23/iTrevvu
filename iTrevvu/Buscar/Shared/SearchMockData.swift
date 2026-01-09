import Foundation

enum SearchMockData {

    static let users: [PublicUser] = [
        .init(
            id: UUID(),
            username: "ana_run",
            displayName: "Ana",
            bio: "Running & hábitos 🏃‍♀️",
            followers: 1240,
            following: 310,
            workouts: 210,
            isFollowing: true
        ),
        .init(
            id: UUID(),
            username: "marcos_gym",
            displayName: "Marcos",
            bio: "Fuerza · Powerbuilding 💪",
            followers: 5820,
            following: 220,
            workouts: 560,
            isFollowing: false
        ),
        .init(
            id: UUID(),
            username: "pablo",
            displayName: "Pablo",
            bio: "Ciclismo y montaña 🚴‍♂️",
            followers: 980,
            following: 180,
            workouts: 120,
            isFollowing: false
        ),
        .init(
            id: UUID(),
            username: "maria",
            displayName: "María",
            bio: "Yoga · movilidad 🧘‍♀️",
            followers: 2100,
            following: 400,
            workouts: 340,
            isFollowing: true
        )
    ]

    static func posts(for userId: UUID) -> [PublicPost] {
        let now = Date()
        var result: [PublicPost] = []
        result.reserveCapacity(24)

        for i in 0..<24 {
            let kind: MediaKind = (i % 5 == 0) ? .clip : .photo
            let caption: String? = (i % 3 == 0) ? "Sesión \(i) 🔥" : nil
            let createdAt = now.addingTimeInterval(TimeInterval(-i * 3600))
            let likes = Int.random(in: 10...3000)
            let comments = Int.random(in: 0...140)

            let post = PublicPost(
                id: UUID(),
                authorId: userId,
                kind: kind,
                caption: caption,
                createdAt: createdAt,
                likes: likes,
                comments: comments
            )
            result.append(post)
        }

        return result
    }

    static func explorePosts() -> [PublicPost] {
        let now = Date()
        let ids = users.map(\.id)

        var result: [PublicPost] = []
        result.reserveCapacity(60)

        for i in 0..<60 {
            let authorId = ids[i % ids.count]
            let kind: MediaKind = (i % 6 == 0) ? .clip : .photo
            let caption: String? = (i % 4 == 0) ? "Explorar \(i)" : nil
            let createdAt = now.addingTimeInterval(TimeInterval(-i * 1800))
            let likes = Int.random(in: 50...6000)
            let comments = Int.random(in: 0...200)

            let post = PublicPost(
                id: UUID(),
                authorId: authorId,
                kind: kind,
                caption: caption,
                createdAt: createdAt,
                likes: likes,
                comments: comments
            )
            result.append(post)
        }

        return result
    }
}

import SwiftUI

struct InicioView: View {

    @State private var selectedTab: FeedTab = .forYou
    @State private var posts: [FeedPost] = FeedMockData.samplePosts()

    @State private var goToDM = false
    @State private var goToNotifs = false

    @State private var showCreatePost = false
    @State private var createMode: CreatePostView.Mode = .text

    @State private var stories: [StoryItem] = [
        .init(id: UUID(), username: "usuario_fit", displayName: "Carlos", hasNew: true, isMe: true),
        .init(id: UUID(), username: "ana_run", displayName: "Ana", hasNew: true, isMe: false),
        .init(id: UUID(), username: "marcos_gym", displayName: "Marcos", hasNew: false, isMe: false),
        .init(id: UUID(), username: "pablo", displayName: "Pablo", hasNew: true, isMe: false),
        .init(id: UUID(), username: "maria", displayName: "María", hasNew: true, isMe: false)
    ]

    // MARK: - Feed filter
    private var visiblePosts: [FeedPost] {
        switch selectedTab {
        case .forYou:
            return posts

        case .following:
            let followingUsernames: Set<String> = ["ana_run", "marcos_gym"]
            return posts.filter { followingUsernames.contains($0.author.username) }

        case .clips:
            let onlyVideos = posts.filter { post in
                if case .media(_, let items) = post.content {
                    return items.contains {
                        if case .video = $0.type { return true }
                        return false
                    }
                }
                return false
            }
            return onlyVideos.isEmpty ? posts : onlyVideos
        }
    }

    // MARK: - Swipe gesture (izquierda -> DM)
    private var swipeToDMGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height

                // 👈 Swipe claro hacia la IZQUIERDA
                if horizontal < -90 && abs(horizontal) > abs(vertical) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        goToDM = true
                    }
                }
            }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    FeedTopBar(
                        onDM: {
                            withAnimation(.easeInOut(duration: 0.22)) { goToDM = true }
                        },
                        onNotifications: {
                            withAnimation(.easeInOut(duration: 0.22)) { goToNotifs = true }
                        }
                    )
                    .padding(.top, 2)

                    FeedTabPicker(selected: $selectedTab)

                    StoriesRow(stories: stories) { _ in }
                        .padding(.horizontal, -16)

                    CreatePostComposerCard(
                        onTextPost: { createMode = .text; showCreatePost = true },
                        onMediaPost: { createMode = .media; showCreatePost = true },
                        onWorkoutPost: { createMode = .workout; showCreatePost = true }
                    )
                    .padding(.top, 2)

                    VStack(spacing: 12) {
                        ForEach(Array(visiblePosts.enumerated()), id: \.element.id) { _, post in
                            if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                                FeedPostCard(post: $posts[idx]) { }
                                    .background(
                                        NavigationLink("", destination: PostDetailView(post: posts[idx]))
                                            .opacity(0)
                                    )
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(FeedBrand.bg)
            .navigationBarHidden(true)
            .simultaneousGesture(swipeToDMGesture)
            .navigationDestination(isPresented: $goToDM) {
                DirectMessagesView()
                    .navigationBarTitleDisplayMode(.inline)
                    .tint(FeedBrand.red)
            }
            .navigationDestination(isPresented: $goToNotifs) {
                NotificationsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .tint(FeedBrand.red)
            }
            .sheet(isPresented: $showCreatePost) {
                NavigationStack {
                    CreatePostView(mode: createMode) { newPost in
                        posts.insert(newPost, at: 0)
                        showCreatePost = false
                    } onCancel: {
                        showCreatePost = false
                    }
                }
            }
        }
        .tint(FeedBrand.red)
    }
}

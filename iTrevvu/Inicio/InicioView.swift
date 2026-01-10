import SwiftUI

struct InicioView: View {

    // Side menu
    @State private var isMenuOpen = false
    private let menuWidth: CGFloat = 320

    // Navegación
    @State private var goToDM = false
    @State private var goToNotifs = false
    @State private var goToBuscar = false
    @State private var goToPerfil = false
    @State private var goToAjustes = false

    // Feed (tu estado actual)
    @State private var selectedTab: FeedTab = .forYou
    @State private var posts: [FeedPost] = FeedMockData.samplePosts()

    @State private var showCreatePost = false
    @State private var createMode: CreatePostView.Mode = .text

    @State private var stories: [StoryItem] = [
        .init(id: UUID(), username: "usuario_fit", displayName: "Carlos", hasNew: true, isMe: true),
        .init(id: UUID(), username: "ana_run", displayName: "Ana", hasNew: true, isMe: false),
        .init(id: UUID(), username: "marcos_gym", displayName: "Marcos", hasNew: false, isMe: false),
        .init(id: UUID(), username: "pablo", displayName: "Pablo", hasNew: true, isMe: false),
        .init(id: UUID(), username: "maria", displayName: "María", hasNew: true, isMe: false)
    ]

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

    var body: some View {
        NavigationStack {
            SideMenuContainer(
                isOpen: $isMenuOpen,
                menuWidth: menuWidth,
                menu: {
                    AnyView(
                        SideMenuView(
                            onClose: { isMenuOpen = false },
                            goToDM: $goToDM,
                            goToNotifs: $goToNotifs,
                            goToBuscar: $goToBuscar,
                            goToPerfil: $goToPerfil,
                            goToAjustes: $goToAjustes
                        )
                    )
                },
                content: {
                    VStack(spacing: 0) {

                        // TopBar Twitter-like
                        HomeTopBar(onAvatarTap: {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.92)) {
                                isMenuOpen.toggle()
                            }
                        })

                        // Feed
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 14) {

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
                    }
                    .background(FeedBrand.bg)
                }
            )
            .navigationBarHidden(true)

            // Navegación push (se ve el desplazamiento)
            .navigationDestination(isPresented: $goToDM) {
                DirectMessagesView()
            }
            .navigationDestination(isPresented: $goToNotifs) {
                NotificationsView()
            }
            .navigationDestination(isPresented: $goToBuscar) {
                BuscarView()
            }
            .navigationDestination(isPresented: $goToPerfil) {
                PerfilView()
            }
            .navigationDestination(isPresented: $goToAjustes) {
                AjustesView(onSignOutTapped: { /* conecta con tu auth */ })
            }

            // Crear post
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

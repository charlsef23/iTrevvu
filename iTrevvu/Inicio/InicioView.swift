import SwiftUI

struct InicioView: View {

    @State private var posts: [FeedPost] = FeedMockData.samplePosts()

    @State private var showDM = false
    @State private var showNotifs = false
    @State private var showCreatePost = false

    @State private var createMode: CreatePostView.Mode = .text

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    FeedTopBar(
                        onDM: { showDM = true },
                        onNotifications: { showNotifs = true }
                    )

                    CreatePostComposerCard(
                        onTextPost: {
                            createMode = .text
                            showCreatePost = true
                        },
                        onMediaPost: {
                            createMode = .media
                            showCreatePost = true
                        },
                        onWorkoutPost: {
                            createMode = .workout
                            showCreatePost = true
                        }
                    )

                    VStack(spacing: 12) {
                        ForEach($posts) { $post in
                            FeedPostCard(post: $post) {
                                // abrir detalle
                            }
                            .background(
                                NavigationLink("", destination: PostDetailView(post: post))
                                    .opacity(0)
                            )
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(FeedBrand.bg)
            .navigationBarHidden(true)
            .sheet(isPresented: $showDM) {
                NavigationStack { DirectMessagesView() }
            }
            .sheet(isPresented: $showNotifs) {
                NavigationStack { NotificationsView() }
            }
            .sheet(isPresented: $showCreatePost) {
                NavigationStack {
                    CreatePostView(mode: createMode) { newPost in
                        // inserta arriba del feed
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

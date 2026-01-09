import SwiftUI

struct UserProfileView: View {
    @State var user: PublicUser

    @State private var selectedKind: MediaKind = .photo
    @State private var posts: [PublicPost] = []
    @State private var selectedPost: PublicPost? = nil

    private var filteredPosts: [PublicPost] {
        posts.filter { $0.kind == selectedKind }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {

                ProfileHeaderCard(user: $user)

                Picker("Contenido", selection: $selectedKind) {
                    ForEach(MediaKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top, 2)

                MediaGrid(posts: filteredPosts) { post in
                    selectedPost = post
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(SearchBrand.bg)
        .navigationTitle("@\(user.username)")
        .navigationBarTitleDisplayMode(.inline)
        .tint(SearchBrand.red)
        .onAppear {
            if posts.isEmpty {
                posts = SearchMockData.posts(for: user.id)
            }
        }
        .navigationDestination(item: $selectedPost) { post in
            PostViewerView(user: user, post: post)
        }
    }
}

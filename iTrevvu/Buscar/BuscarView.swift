import SwiftUI

struct BuscarView: View {

    @State private var query: String = ""
    @State private var users: [PublicUser] = SearchMockData.users
    @State private var explorePosts: [PublicPost] = SearchMockData.explorePosts()

    @State private var selectedPost: PublicPost? = nil
    @State private var selectedUser: PublicUser? = nil

    private var filteredUsers: [PublicUser] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return users }
        return users.filter {
            $0.username.localizedCaseInsensitiveContains(q) ||
            $0.displayName.localizedCaseInsensitiveContains(q)
        }
    }

    private func userFor(post: PublicPost) -> PublicUser {
        users.first(where: { $0.id == post.authorId }) ?? users.first!
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {

                    // 🔍 RESULTADOS DE USUARIOS
                    if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Usuarios")
                                .font(.title3.bold())

                            VStack(spacing: 8) {
                                ForEach(filteredUsers) { user in
                                    Button {
                                        selectedUser = user
                                    } label: {
                                        UserSearchRowRed(user: user)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // 📸 EXPLORAR
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explorar")
                            .font(.title3.bold())

                        MediaGrid(posts: explorePosts) { post in
                            selectedPost = post
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(SearchBrand.bg)
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar usuarios"
            )
            .tint(SearchBrand.red)
            .navigationDestination(item: $selectedUser) { user in
                UserProfileView(user: user)
            }
            .navigationDestination(item: $selectedPost) { post in
                let user = userFor(post: post)
                PostViewerView(user: user, post: post)
            }
        }
    }
}

import SwiftUI

struct MediaGrid: View {
    let posts: [PublicPost]
    let onTap: (PublicPost) -> Void

    private let cols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: cols, spacing: 8) {
            ForEach(posts) { post in
                MediaGridCell(post: post)
                    .onTapGesture { onTap(post) }
            }
        }
    }
}

import SwiftUI

struct PostDetailView: View {
    let post: FeedPost

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // En detalle puedes reutilizar el contenido
                switch post.content {
                case .text(let text):
                    Text(text).font(.body)

                case .media(let text, let items):
                    MediaPostView(text: text, items: items)

                case .workout(let text, let workout):
                    WorkoutPostView(text: text, workout: workout)
                }
            }
            .padding(16)
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }
}

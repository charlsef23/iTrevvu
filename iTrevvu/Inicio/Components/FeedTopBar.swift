import SwiftUI

struct FeedTopBar: View {
    let onDM: () -> Void
    let onNotifications: () -> Void

    var body: some View {
        HStack {
            Text("Inicio")
                .font(.headline.bold())

            Spacer()

            Button(action: onNotifications) {
                Image(systemName: "heart")
                    .font(.headline)
            }

            Button(action: onDM) {
                Image(systemName: "paperplane")
                    .font(.headline)
            }
        }
        .foregroundStyle(FeedBrand.red)
    }
}

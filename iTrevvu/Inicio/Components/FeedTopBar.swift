import SwiftUI

struct FeedTopBar: View {
    let onDM: () -> Void
    let onNotifications: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Text("iTrevvu")
                .font(.title3.bold())
                .foregroundStyle(.primary)

            Spacer()

            Button(action: onNotifications) {
                Image(systemName: "heart")
                    .font(.headline)
                    .foregroundStyle(FeedBrand.red)
            }
            .buttonStyle(.plain)

            Button(action: onDM) {
                Image(systemName: "paperplane")
                    .font(.headline)
                    .foregroundStyle(FeedBrand.red)
            }
            .buttonStyle(.plain)
        }
    }
}

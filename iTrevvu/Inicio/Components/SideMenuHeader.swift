import SwiftUI

struct SideMenuHeader: View {
    let username: String
    let displayName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(Color.gray.opacity(0.18))
                .frame(width: 54, height: 54)
                .overlay(
                    Circle().strokeBorder(FeedBrand.red.opacity(0.25), lineWidth: 1)
                )

            Text(displayName)
                .font(.title3.bold())

            Text("@\(username)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider().opacity(0.6)
        }
        .padding(.bottom, 4)
    }
}

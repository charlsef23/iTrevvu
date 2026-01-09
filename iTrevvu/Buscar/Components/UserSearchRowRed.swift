import SwiftUI

struct UserSearchRowRed: View {
    let user: PublicUser

    var body: some View {
        HStack(spacing: 14) {

            // Avatar
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.18))
                Circle()
                    .strokeBorder(SearchBrand.red.opacity(0.35), lineWidth: 1)

                Text(initials(user.displayName))
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundStyle(SearchBrand.red)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(SearchBrand.red.opacity(0.6))
        }
        .padding(12)
        .background(SearchBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: SearchBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SearchBrand.corner, style: .continuous)
                .strokeBorder(SearchBrand.red.opacity(0.15), lineWidth: 1)
        )
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let a = parts.first?.first.map(String.init) ?? "U"
        let b = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }
}

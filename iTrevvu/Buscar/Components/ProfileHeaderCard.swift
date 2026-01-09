import SwiftUI

struct ProfileHeaderCard: View {
    @Binding var user: PublicUser

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Circle()
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 78, height: 78)
                    .overlay(Text(initials(user.displayName)).font(.headline.bold()).foregroundStyle(.secondary))

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.title3.bold())
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(user.bio)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            HStack(spacing: 12) {
                Stat(title: "Entrenos", value: "\(user.workouts)")
                Stat(title: "Seguidores", value: "\(user.followers)")
                Stat(title: "Siguiendo", value: "\(user.following)")
            }

            Button {
                user.isFollowing.toggle()
            } label: {
                Text(user.isFollowing ? "Siguiendo" : "Seguir")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(SearchBrand.red)
        }
        .padding(14)
        .background(SearchBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: SearchBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SearchBrand.corner, style: .continuous)
                .strokeBorder(SearchBrand.red.opacity(0.10), lineWidth: 1)
        )
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let a = parts.first?.first.map(String.init) ?? "U"
        let b = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }
}

private struct Stat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.headline.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

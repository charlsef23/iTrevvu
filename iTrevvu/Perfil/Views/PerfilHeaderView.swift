import SwiftUI

struct PerfilHeaderView: View {
    private enum Brand {
        static let red = Color.red
        static let card = Color(.secondarySystemBackground)
        static let corner: CGFloat = 22
    }

    let username: String
    let fullName: String
    let bio: String

    var body: some View {
        ZStack {
            // Fondo hero con degradado rojo MUY suave
            RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Brand.red.opacity(0.22),
                            Brand.red.opacity(0.08),
                            Color(.secondarySystemBackground).opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 14) {
                    AvatarCircle(initials: initials(from: fullName))
                        .frame(width: 86, height: 86)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(fullName.isEmpty ? "@\(username)" : fullName)
                            .font(.title3.bold())

                        Text("@\(username)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Brand.red)

                        if !bio.isEmpty {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .padding(.top, 2)
                        }
                    }

                    Spacer()
                }

                // “chips” / tags
                HStack(spacing: 8) {
                    TagPill(text: "Fitness", systemImage: "flame.fill")
                    TagPill(text: "Progreso", systemImage: "chart.line.uptrend.xyaxis")
                    TagPill(text: "Constancia", systemImage: "calendar")
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                .strokeBorder(Brand.red.opacity(0.12), lineWidth: 1)
        )
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ").map(String.init)
        let first = parts.first?.first.map(String.init) ?? "U"
        let second = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }
}

private struct AvatarCircle: View {
    private enum Brand { static let red = Color.red }

    let initials: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.18))

            // anillo rojo
            Circle()
                .strokeBorder(Brand.red.opacity(0.9), lineWidth: 3)

            // brillo interior sutil
            Circle()
                .inset(by: 4)
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)

            Text(initials)
                .font(.title2.bold())
                .foregroundStyle(.primary.opacity(0.85))
        }
    }
}

private struct TagPill: View {
    private enum Brand { static let red = Color.red }

    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(Brand.red)
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(Brand.red.opacity(0.10))
        .clipShape(Capsule())
    }
}

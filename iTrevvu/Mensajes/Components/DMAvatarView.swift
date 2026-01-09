import SwiftUI

struct DMAvatarView: View {
    let name: String
    var size: CGFloat = 44

    private var initials: String {
        let parts = name.split(separator: " ").map(String.init)
        let a = parts.first?.first.map(String.init) ?? "U"
        let b = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }

    var body: some View {
        ZStack {
            Circle().fill(Color.gray.opacity(0.18))
            Circle().strokeBorder(DMBrand.red.opacity(0.25), lineWidth: 1)
            Text(initials).font(.caption.bold())
        }
        .frame(width: size, height: size)
    }
}

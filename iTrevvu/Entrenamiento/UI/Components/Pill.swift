import SwiftUI

/// Pequeña "pastilla" para tags (tipo, duración, etc.)
struct Pill: View {
    let text: String
    let tint: Color

    init(text: String, tint: Color) {
        self.text = text
        self.tint = tint
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint == .secondary ? .primary : tint)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(tint.opacity(0.14))
            )
    }
}

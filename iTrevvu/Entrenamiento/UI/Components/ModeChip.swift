import SwiftUI

struct ModeChip: View {
    let title: String
    let isOn: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isOn ? .white : .primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    Capsule().fill(isOn ? accent : Color.gray.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }
}

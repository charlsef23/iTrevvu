import SwiftUI

struct MessageComposer: View {
    @Binding var text: String
    let onTapPlus: () -> Void
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onTapPlus) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(DMBrand.red)
            }
            .buttonStyle(.plain)

            TextField("Mensaje…", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.headline)
                    .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : DMBrand.red)
            }
            .buttonStyle(.plain)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}

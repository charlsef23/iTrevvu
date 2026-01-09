import SwiftUI

struct AttachmentPreviewSendView: View {
    let attachment: DMAttachment
    let onSend: (String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var caption: String = ""

    var body: some View {
        VStack(spacing: 14) {
            AttachmentCard(attachment: attachment)

            TextField("Añadir texto…", text: $caption, axis: .vertical)
                .lineLimit(1...4)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button {
                onSend(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : caption)
                dismiss()
            } label: {
                Text("Enviar")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(DMBrand.red)

            Spacer()
        }
        .padding(16)
        .navigationTitle("Enviar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

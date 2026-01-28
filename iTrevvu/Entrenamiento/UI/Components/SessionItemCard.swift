import SwiftUI

struct SessionItemCard<Content: View>: View {

    let title: String
    let accent: Color
    let onAddSet: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(accent))
                    Image(systemName: "dumbbell.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(accent)
                }
                .frame(width: 40, height: 40)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Spacer()

                Button {
                    onAddSet()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(accent)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            content()
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

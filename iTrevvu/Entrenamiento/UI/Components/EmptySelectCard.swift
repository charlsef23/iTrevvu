import SwiftUI

struct EmptySelectCard: View {
    let title: String
    let subtitle: String
    let accent: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(accent))
                    Image(systemName: "plus")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(TrainingBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

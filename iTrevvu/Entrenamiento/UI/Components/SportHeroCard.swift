import SwiftUI

struct SportHeroCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(TrainingBrand.softFill(accent))
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }
}

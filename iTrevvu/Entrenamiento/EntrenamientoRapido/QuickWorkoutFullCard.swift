import SwiftUI

struct QuickWorkoutFullCard: View {
    let type: QuickWorkoutType
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(type.uiColor.opacity(0.15))

            VStack(alignment: .leading, spacing: 16) {

                Spacer()

                Image(systemName: type.icono)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(type.uiColor)

                Text(type.nombre)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Toca para empezar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

            }
            .padding(32)
        }
        .frame(height: height)
        .padding(.horizontal, 16)
    }
}

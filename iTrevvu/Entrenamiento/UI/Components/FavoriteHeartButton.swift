import SwiftUI

struct FavoriteHeartButton: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .foregroundStyle(isOn ? TrainingBrand.stats : .secondary)
                .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

struct SectionHeader: View {
    let title: String
    let actionTitle: String?
    var onAction: (() -> Void)? = nil

    init(title: String, actionTitle: String? = nil, onAction: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.onAction = onAction
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.bold())
            Spacer()
            if let actionTitle {
                Button(actionTitle) { onAction?() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TrainingBrand.red)
            }
        }
        .padding(.top, 4)
    }
}

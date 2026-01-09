import SwiftUI

struct FeedTabPicker: View {
    @Binding var selected: FeedTab

    var body: some View {
        HStack(spacing: 10) {
            ForEach(FeedTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        selected = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.subheadline.weight(selected == tab ? .bold : .semibold))
                            .foregroundStyle(selected == tab ? .primary : .secondary)
                            .frame(maxWidth: .infinity)

                        ZStack {
                            Capsule()
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 3)

                            if selected == tab {
                                Capsule()
                                    .fill(FeedBrand.red)
                                    .frame(height: 3)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 2)
    }
}

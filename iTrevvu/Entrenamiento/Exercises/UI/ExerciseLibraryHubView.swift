import SwiftUI

struct ExerciseLibraryHubView: View {
    private let cols = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: cols, spacing: 14) {
                ForEach(ExerciseType.allCases) { type in
                    NavigationLink {
                        ExerciseTypeView(type: type)
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: type.icon)
                                .font(.title2)
                                .foregroundStyle(TrainingBrand.action)

                            Text(type.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, minHeight: 110)
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .navigationTitle("Biblioteca")
        .navigationBarTitleDisplayMode(.inline)
    }
}

import SwiftUI

struct ExerciseLibraryHubView: View {

    @EnvironmentObject private var store: ExerciseStore
    private let cols = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: cols, spacing: 14) {
                ForEach(ExerciseType.allCases) { type in
                    NavigationLink {
                        ExerciseTypeView(type: type)
                            .environmentObject(store)
                    } label: {
                        ExerciseTypeTile(type: type)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Biblioteca")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ExerciseTypeTile: View {
    let type: ExerciseType

    var body: some View {
        let tint = tintFor(type)

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(tint))
                    Image(systemName: type.icon)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(tint)
                }
                .frame(width: 44, height: 44)

                Spacer()
            }

            Text(type.title)
                .font(.headline.bold())
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text("Ver ejercicios")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private func tintFor(_ t: ExerciseType) -> Color {
        switch t {
        case .fuerza, .calistenia, .core:
            return TrainingBrand.action
        case .cardio, .hiit:
            return TrainingBrand.cardio
        case .movilidad, .rehab:
            return TrainingBrand.mobility
        case .deporte, .rutinas:
            return TrainingBrand.custom
        }
    }
}

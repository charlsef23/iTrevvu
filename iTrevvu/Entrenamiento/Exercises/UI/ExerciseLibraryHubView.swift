import SwiftUI

struct ExerciseLibraryHubView: View {

    /// Si lo pasas desde IniciarEntrenamientoView, podrás “devolver” ejercicios seleccionados.
    var onStartWithExercises: (([Exercise]) -> Void)? = nil

    private let cols = [GridItem(.flexible()), GridItem(.flexible())]

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ExerciseStore

    @State private var showMultiPicker = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                header

                LazyVGrid(columns: cols, spacing: 14) {
                    ForEach(ExerciseType.allCases) { type in
                        NavigationLink {
                            ExerciseTypeView(type: type, onStartWithExercises: onStartWithExercises)
                                .environmentObject(store)
                        } label: {
                            TypeCard(type: type)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Biblioteca")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMultiPicker) {
            ExercisePickerView(mode: .multiPick { picked in
                onStartWithExercises?(picked)
                dismiss()
            })
            .environmentObject(store)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Elige una categoría o selecciona varios ejercicios para entrenar.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showMultiPicker = true
            } label: {
                HStack {
                    Image(systemName: "checklist")
                    Text("Seleccionar ejercicios para entrenar ahora")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(TrainingBrand.stats)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
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

private struct TypeCard: View {
    let type: ExerciseType

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(TrainingBrand.softFill(TrainingBrand.action))
                    Image(systemName: type.icon)
                        .font(.headline.bold())
                        .foregroundStyle(TrainingBrand.action)
                }
                .frame(width: 44, height: 44)

                Spacer()
            }

            Text(type.title)
                .font(.headline.bold())
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text("Ver ejercicios")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }
}

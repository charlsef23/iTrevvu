import SwiftUI

struct ExercisePickerView: View {

    enum Mode {
        case browse
        case pick((Exercise) -> Void)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ExerciseStore

    @State private var searchText: String = ""
    @State private var onlyFavorites: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                searchBar

                Toggle(isOn: $onlyFavorites) {
                    Text("Solo favoritos")
                        .font(.subheadline.weight(.semibold))
                }
                .tint(TrainingBrand.stats)
                .padding(.horizontal, 16)

                content
            }
            .padding(.top, 8)
            .background(TrainingBrand.bg)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    // MARK: - UI

    private var title: String {
        switch mode {
        case .browse: return "Ejercicios"
        case .pick: return "Seleccionar ejercicio"
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Buscar ejercicio…", text: $searchText)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading {
            ProgressView()
                .padding(.top, 24)
        } else {
            let results = store.search(
                text: searchText,
                onlyFavorites: onlyFavorites
            )

            if results.isEmpty {
                Text("No hay resultados.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 24)
            } else {
                List {
                    ForEach(results) { ex in
                        row(for: ex)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
            }
        }
    }

    private func row(for ex: Exercise) -> some View {
        Button {
            switch mode {
            case .browse:
                // en browse no hacemos nada (puedes abrir detalle si quieres)
                break

            case .pick(let onPick):
                onPick(ex)
                dismiss()
            }
        } label: {
            HStack(spacing: 12) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(TrainingBrand.softFill(ex.isCustom ? TrainingBrand.custom : TrainingBrand.action))

                    Image(systemName: ex.isCustom ? "person.fill" : "dumbbell.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ex.isCustom ? TrainingBrand.custom : TrainingBrand.action)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ex.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("\(ex.primary.title) · \(ex.category.rawValue.capitalized)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    Task {
                        await store.toggleFavorite(exerciseId: ex.id, isCustom: ex.isCustom)
                    }
                } label: {
                    Image(systemName: store.isFavorite(ex.id) ? "heart.fill" : "heart")
                        .foregroundStyle(store.isFavorite(ex.id) ? TrainingBrand.stats : .secondary)
                }
                .buttonStyle(.plain)

                if case .pick = mode {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 6)
                }
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

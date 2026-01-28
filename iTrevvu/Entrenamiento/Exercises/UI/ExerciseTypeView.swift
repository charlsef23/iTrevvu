import SwiftUI

struct ExerciseTypeView: View {
    let type: ExerciseType

    var onStartWithExercises: (([Exercise]) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ExerciseStore

    @State private var search = ""
    @State private var selectedIds: Set<UUID> = []

    private var exercises: [Exercise] { store.byType[type] ?? [] }

    var body: some View {
        VStack(spacing: 0) {

            searchBar

            if store.isLoading {
                ProgressView().padding(.top, 24)
                Spacer()
            } else if let msg = store.errorMessage {
                Text(msg).foregroundStyle(.secondary).padding()
                Spacer()
            } else {
                let results = localFilter(exercises, search: search)

                List {
                    ForEach(results) { ex in
                        Button {
                            toggle(ex)
                        } label: {
                            ExerciseRowCard(
                                ex: ex,
                                isSelected: selectedIds.contains(ex.id),
                                showSelection: true,
                                onFav: { Task { await store.toggleFavorite(exerciseId: ex.id) } },
                                isFav: store.isFavorite(ex.id)
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(TrainingBrand.bg)
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if onStartWithExercises != nil {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Añadir") { commit() }
                        .disabled(selectedIds.isEmpty)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if onStartWithExercises != nil {
                bottomBar
            }
        }
        .task { await store.load(type: type) }
        .onChange(of: search) { _, newValue in
            Task {
                try? await Task.sleep(nanoseconds: 250_000_000)
                if newValue == search {
                    // si tu store soporta server search úsalo, si no, quítalo:
                    await store.load(type: type, search: newValue.isEmpty ? nil : newValue)
                }
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            Divider().opacity(0.6)

            Button {
                commit()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Añadir \(selectedIds.count) ejercicio(s)")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(TrainingBrand.stats)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(selectedIds.isEmpty)
            .opacity(selectedIds.isEmpty ? 0.55 : 1)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(TrainingBrand.bg)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Buscar…", text: $search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

            if !search.isEmpty {
                Button { search = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
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
        .padding(16)
    }

    private func toggle(_ ex: Exercise) {
        if selectedIds.contains(ex.id) { selectedIds.remove(ex.id) }
        else { selectedIds.insert(ex.id) }
    }

    private func commit() {
        guard let cb = onStartWithExercises else { return }
        let picked = exercises.filter { selectedIds.contains($0.id) }
        cb(picked)
        dismiss()
    }

    private func localFilter(_ items: [Exercise], search: String) -> [Exercise] {
        let s = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return items }
        let needle = s.folding(options: .diacriticInsensitive, locale: .current).lowercased()

        return items.filter { ex in
            let name = ex.nombre.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            if name.contains(needle) { return true }
            let aliases = (ex.aliases ?? []).map { $0.folding(options: .diacriticInsensitive, locale: .current).lowercased() }
            return aliases.contains(where: { $0.contains(needle) })
        }
    }
}

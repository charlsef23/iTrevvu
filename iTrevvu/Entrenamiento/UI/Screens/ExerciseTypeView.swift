import SwiftUI

struct ExerciseTypeView: View {
    let type: ExerciseType

    @StateObject private var store = ExerciseStore(client: SupabaseManager.shared.client)
    @State private var search: String = ""
    @State private var onlyFavorites: Bool = false

    private var base: [Exercise] { store.byType[type] ?? [] }

    private var results: [Exercise] {
        var out = base

        if onlyFavorites {
            out = out.filter { store.isFavorite($0.id) }
        }

        let s = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return out }

        let needle = s.folding(options: .diacriticInsensitive, locale: .current).lowercased()

        return out.filter { ex in
            let name = ex.nombre.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            if name.contains(needle) { return true }

            let aliases = (ex.aliases ?? []).map {
                $0.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            }
            return aliases.contains(where: { $0.contains(needle) })
        }
    }

    var body: some View {
        VStack(spacing: 12) {

            headerFilters

            if store.isLoading {
                ProgressView().padding(.top, 24)
                Spacer()
            } else if let msg = store.errorMessage {
                Text(msg)
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
            } else {
                if results.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(results) { ex in
                            ExerciseRowCard(
                                ex: ex,
                                isFavorite: store.isFavorite(ex.id),
                                onFavorite: {
                                    Task { await store.toggleFavorite(exerciseId: ex.id) }
                                }
                            )
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
        .padding(.top, 8)
        .background(TrainingBrand.bg)
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.load(type: type) } // ✅ solo carga por tipo
    }

    private var headerFilters: some View {
        VStack(spacing: 10) {
            searchBar

            Toggle(isOn: $onlyFavorites) {
                Text("Solo favoritos")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(TrainingBrand.stats)
            .padding(.horizontal, 16)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Buscar…", text: $search)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()

            if !search.isEmpty {
                Button { search = "" } label: {
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

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No hay resultados")
                .font(.headline.bold())
            Text("Prueba con otro nombre o quita el filtro de favoritos.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.top, 24)
    }
}


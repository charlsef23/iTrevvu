import SwiftUI

struct ExerciseTypeView: View {
    let type: ExerciseType
    @StateObject private var store = ExerciseStore()
    @State private var search = ""

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
                List {
                    let favs = exercises.filter { store.isFavorite($0.id) }
                    if !favs.isEmpty {
                        Section("Favoritos") {
                            ForEach(favs) { ex in
                                row(ex)
                            }
                        }
                    }

                    Section(type.title) {
                        ForEach(exercises) { ex in
                            row(ex)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.load(type: type) }
        .onChange(of: search) { _, newValue in
            Task {
                try? await Task.sleep(nanoseconds: 250_000_000)
                if newValue == search {
                    await store.load(type: type, search: newValue.isEmpty ? nil : newValue)
                }
            }
        }
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

    private func row(_ ex: Exercise) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ex.nombre).font(.headline)
                Text((ex.musculo_principal ?? "—") + " · " + ex.tipo_medicion.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                Task { await store.toggleFavorite(exerciseId: ex.id) }
            } label: {
                Image(systemName: store.isFavorite(ex.id) ? "heart.fill" : "heart")
                    .foregroundStyle(store.isFavorite(ex.id) ? TrainingBrand.stats : .secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

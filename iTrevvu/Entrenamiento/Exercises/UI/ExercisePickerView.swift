import SwiftUI

struct ExercisePickerView: View {

    enum Mode {
        case browse
        case pick((Exercise) -> Void)
    }

    let mode: Mode
    let type: ExerciseType?   // ✅ opcional: si quieres filtrar por tipo desde fuera

    init(mode: Mode, type: ExerciseType? = nil) {
        self.mode = mode
        self.type = type
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ExerciseStore

    @State private var searchText: String = ""
    @State private var onlyFavorites: Bool = false
    @State private var selectedType: ExerciseType = .fuerza

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                if type == nil {
                    typePicker
                }

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
            .task {
                // ✅ precarga
                let t = type ?? selectedType
                await store.load(type: t)
            }
            .onChange(of: selectedType) {
                guard type == nil else { return }
                Task { await store.load(type: selectedType) }
            }
            .onChange(of: searchText) {
                // nada: filtramos local, no hace falta recargar
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

    private var typePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ExerciseType.allCases) { t in
                    Button {
                        selectedType = t
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: t.icon)
                                .font(.caption.weight(.bold))
                            Text(t.title)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(selectedType == t ? .white : .primary)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule().fill(selectedType == t ? TrainingBrand.action : Color.gray.opacity(0.10))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
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
                Button { searchText = "" } label: {
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
            let t = type ?? selectedType
            let base = store.byType[t] ?? []
            let results = filterLocal(base)

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

    private func filterLocal(_ items: [Exercise]) -> [Exercise] {
        var out = items

        if onlyFavorites {
            out = out.filter { store.isFavorite($0.id) }
        }

        let s = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
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

    private func row(for ex: Exercise) -> some View {
        Button {
            switch mode {
            case .browse:
                break
            case .pick(let onPick):
                onPick(ex)
                dismiss()
            }
        } label: {
            HStack(spacing: 12) {

                // ✅ icono según tipo + si es personal (autor_id != nil)
                let isPersonal = (ex.autor_id != nil)

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(TrainingBrand.softFill(isPersonal ? TrainingBrand.custom : TrainingBrand.action))

                    Image(systemName: isPersonal ? "person.fill" : "dumbbell.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isPersonal ? TrainingBrand.custom : TrainingBrand.action)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ex.nombre)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(ex.tipo.title)
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

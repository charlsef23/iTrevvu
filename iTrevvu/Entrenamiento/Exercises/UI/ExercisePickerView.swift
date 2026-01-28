import SwiftUI

struct ExercisePickerView: View {

    enum Mode {
        case browse
        case pick((Exercise) -> Void)
        case multiPick(([Exercise]) -> Void)
    }

    let mode: Mode
    let type: ExerciseType?

    init(mode: Mode, type: ExerciseType? = nil) {
        self.mode = mode
        self.type = type
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ExerciseStore

    @State private var searchText: String = ""
    @State private var onlyFavorites: Bool = false
    @State private var selectedType: ExerciseType = .fuerza

    // ✅ multi-select
    @State private var selectedIds: Set<UUID> = []

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

                if case .multiPick = mode {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Listo") { commitMultiPick() }
                            .disabled(selectedIds.isEmpty)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if case .multiPick = mode {
                    multiPickBar
                }
            }
            .task {
                let t = type ?? selectedType
                await store.load(type: t)
            }
            .onChange(of: selectedType) { _, _ in
                guard type == nil else { return }
                Task { await store.load(type: selectedType) }
            }
        }
    }

    // MARK: - UI

    private var title: String {
        switch mode {
        case .browse: return "Ejercicios"
        case .pick: return "Seleccionar ejercicio"
        case .multiPick: return "Seleccionar ejercicios"
        }
    }

    private var typePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ExerciseType.allCases) { t in
                    Button {
                        selectedType = t
                        selectedIds.removeAll()
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
            ProgressView().padding(.top, 24)
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
                        pickerRow(for: ex)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var multiPickBar: some View {
        VStack(spacing: 10) {
            Divider().opacity(0.6)

            Button {
                commitMultiPick()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(selectedIds.isEmpty ? "Selecciona ejercicios" : "Añadir \(selectedIds.count) ejercicio(s)")
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

    // MARK: - Logic

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

    private func pickerRow(for ex: Exercise) -> some View {
        Button {
            switch mode {
            case .browse:
                break

            case .pick(let onPick):
                onPick(ex)
                dismiss()

            case .multiPick:
                toggleSelect(ex)
            }
        } label: {
            ExerciseRowCard(
                ex: ex,
                isSelected: selectedIds.contains(ex.id),
                showSelection: isMultiPick,
                onFav: { Task { await store.toggleFavorite(exerciseId: ex.id) } },
                isFav: store.isFavorite(ex.id)
            )
        }
        .buttonStyle(.plain)
    }

    private var isMultiPick: Bool {
        if case .multiPick = mode { return true }
        return false
    }

    private func toggleSelect(_ ex: Exercise) {
        if selectedIds.contains(ex.id) {
            selectedIds.remove(ex.id)
        } else {
            selectedIds.insert(ex.id)
        }
    }

    private func commitMultiPick() {
        guard case .multiPick(let onPick) = mode else { return }
        let t = type ?? selectedType
        let base = store.byType[t] ?? []
        let results = filterLocal(base)
        let picked = results.filter { selectedIds.contains($0.id) }
        onPick(picked)
        dismiss()
    }
}

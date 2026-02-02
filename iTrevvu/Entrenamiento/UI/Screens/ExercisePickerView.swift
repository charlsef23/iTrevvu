import SwiftUI

struct ExercisePickerView: View {

    enum Mode {
        case browse
        case pick((Exercise) -> Void)
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                if type == nil {
                    typePicker
                }

                SearchFieldCard(text: $searchText, placeholder: "Buscar ejercicio…")

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
                let t = type ?? selectedType
                await store.load(type: t)
            }
            .onChange(of: selectedType) { _, _ in
                guard type == nil else { return }
                Task { await store.load(type: selectedType) }
            }
        }
    }

    private var title: String {
        switch mode {
        case .browse: return "Ejercicios"
        case .pick: return "Seleccionar"
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
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(results) { ex in
                            row(for: ex)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
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

            let aliases = ex.aliases.map {
                $0.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            }
            return aliases.contains(where: { $0.contains(needle) })
        }
    }

    private func row(for ex: Exercise) -> some View {
        let personal = (ex.autor_id != nil)
        let accent = personal ? TrainingBrand.custom : TrainingBrand.action
        let icon = iconForExercise(ex)

        return Button {
            switch mode {
            case .browse:
                break
            case .pick(let onPick):
                onPick(ex)
                dismiss()
            }
        } label: {
            ExerciseRowCardUI(
                title: ex.nombre,
                subtitle: subtitleForExercise(ex),
                leadingIcon: icon,
                accent: accent
            ) {
                FavoriteHeartButton(isOn: store.isFavorite(ex.id)) {
                    Task { await store.toggleFavorite(exerciseId: ex.id) }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func subtitleForExercise(_ ex: Exercise) -> String {
        let muscle = (ex.musculo_principal ?? "—")
        return "\(ex.tipo.title) · \(muscle)"
    }

    private func iconForExercise(_ ex: Exercise) -> String {
        switch ex.tipo {
        case .fuerza: return "dumbbell.fill"
        case .calistenia: return "figure.strengthtraining.traditional"
        case .cardio: return "figure.run"
        case .hiit: return "bolt.fill"
        case .core: return "circle.grid.cross.fill"
        case .movilidad: return "figure.cooldown"
        case .rehab: return "cross.case.fill"
        case .deporte: return "sportscourt.fill"
        case .rutinas: return "list.bullet.rectangle.portrait"
        }
    }
}

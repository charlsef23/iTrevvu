import SwiftUI

struct ExercisePickerView: View {

    enum Mode {
        case pick(onSelect: (Exercise) -> Void)
        case manage
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ExerciseStore

    @State private var query = ""
    @State private var category: ExerciseCategory? = nil
    @State private var muscle: MuscleGroup? = nil
    @State private var equipment: Equipment? = nil
    @State private var onlyFavs = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                filters

                List {
                    ForEach(results) { ex in
                        Button {
                            if case .pick(let onSelect) = mode {
                                onSelect(ex)
                                dismiss()
                            }
                        } label: {
                            ExerciseRow(exercise: ex)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                store.toggleFavorite(ex.id)
                            } label: {
                                Label(store.isFavorite(ex.id) ? "Quitar" : "Favorito",
                                      systemImage: store.isFavorite(ex.id) ? "star.slash" : "star")
                            }
                            .tint(.yellow)

                            if ex.isCustom, case .manage = mode {
                                Button(role: .destructive) {
                                    store.deleteCustom(ex.id)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Ejercicios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
                if case .manage = mode {
                    ToolbarItem(placement: .confirmationAction) {
                        NavigationLink {
                            CreateCustomExerciseView()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "Buscar ejercicio")
    }

    private var results: [Exercise] {
        store.search(
            text: query,
            category: category,
            primary: muscle,
            equipment: equipment,
            onlyFavorites: onlyFavs
        )
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: category?.title ?? "Categoría") {
                    category = next(category, all: [nil, .fuerza, .cardio, .movilidad])
                }

                FilterChip(title: muscle?.title ?? "Músculo") {
                    muscle = next(muscle, all: [nil] + MuscleGroup.allCases)
                }

                FilterChip(title: equipment?.title ?? "Equipo") {
                    equipment = next(equipment, all: [nil] + Equipment.allCases)
                }

                FilterChip(title: onlyFavs ? "Favoritos ✓" : "Favoritos") {
                    onlyFavs.toggle()
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func next<T: Equatable>(_ current: T?, all: [T?]) -> T? {
        guard let idx = all.firstIndex(where: { $0 == current }) else { return all.first ?? nil }
        let nextIdx = all.index(after: idx)
        if nextIdx >= all.endIndex { return all.first ?? nil }
        return all[nextIdx] ?? nil
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    @EnvironmentObject private var store: ExerciseStore

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent(exercise).opacity(0.10))
                Image(systemName: icon(exercise))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent(exercise))
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline.weight(.semibold))
                Text("\(exercise.category.title) · \(exercise.primary.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if store.isFavorite(exercise.id) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .padding(.vertical, 6)
    }

    private func accent(_ ex: Exercise) -> Color {
        switch ex.category {
        case .fuerza: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        }
    }

    private func icon(_ ex: Exercise) -> String {
        switch ex.category {
        case .fuerza: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .movilidad: return "figure.cooldown"
        }
    }
}

private struct FilterChip: View {
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.10))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

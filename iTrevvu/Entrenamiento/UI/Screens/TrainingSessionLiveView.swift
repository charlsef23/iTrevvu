import SwiftUI

struct TrainingSessionLiveView: View {

    let mode: IniciarEntrenamientoView.Mode
    let plan: PlannedSession?
    let exercises: [Exercise]
    let accent: Color

    @StateObject private var store = TrainingSessionStore()

    init(
        mode: IniciarEntrenamientoView.Mode,
        plan: PlannedSession?,
        exercises: [Exercise],
        accent: Color
    ) {
        self.mode = mode
        self.plan = plan
        self.exercises = exercises
        self.accent = accent
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {

                heroCard

                sessionMetaCard

                itemsCard

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Sesión")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(store.isRunning ? "Terminar" : "Empezar") {
                    store.isRunning ? store.stop() : store.start(title: plan?.nombre)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(accent)
            }
        }
        .onAppear {
            // Arranca sesión y mete ejercicios seleccionados
            if !store.isRunning {
                store.start(title: plan?.nombre)
            }
            // Evita duplicados si vuelves atrás/adelante
            let existingIds = Set(store.items.map { $0.exerciseId })
            for ex in exercises where !existingIds.contains(ex.id) {
                store.addExercise(ex)
            }
        }
    }

    // MARK: - Cards

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.14))
                    Image(systemName: store.isRunning ? "timer" : "play.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(plan == nil ? "Sesión rápida" : "Plan de hoy")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(heroTitle)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }

                Spacer()
            }

            if !heroSubtitle.isEmpty {
                Text(heroSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private var sessionMetaCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Estado")
                    .font(.headline.bold())
                Spacer()
                Text(store.isRunning ? "En curso" : "Pausada")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(store.isRunning ? accent : .secondary)
            }

            HStack(spacing: 10) {
                metaPill("\(store.items.count) ejercicios", icon: "list.bullet")
                metaPill(totalSetsText, icon: "square.stack.3d.up")
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private var itemsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Ejercicios")
                    .font(.headline.bold())
                Spacer()
            }

            if store.items.isEmpty {
                Text("No hay ejercicios en la sesión.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            } else {
                VStack(spacing: 10) {
                    ForEach(store.items) { item in
                        itemCard(item)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private func itemCard(_ item: TrainingSessionItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accent.opacity(0.14))
                    Image(systemName: iconForItem(item))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(accent)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.nombre)
                        .font(.subheadline.weight(.semibold))

                    Text(item.tipo.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(role: .destructive) {
                    store.removeItem(item.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 8) {
                ForEach(Array(item.sets.indices), id: \.self) { idx in
                    setRow(itemId: item.id, setIndex: idx, set: item.sets[idx])
                }
            }

            Button {
                store.addSet(to: item.id)
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Añadir set")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(accent)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(accent.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func setRow(itemId: UUID, setIndex: Int, set: TrainingSet) -> some View {
        Button {
            store.toggleSetDone(itemId: itemId, setIndex: setIndex)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: set.completado ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(set.completado ? accent : .secondary)

                Text("Set \(setIndex + 1)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(setSummary(set))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(TrainingBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var heroTitle: String {
        if let plan {
            let n = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
            return n.isEmpty ? plan.tipo.title : n
        }
        return "Entrena ahora"
    }

    private var heroSubtitle: String {
        if let plan {
            return "\(plan.tipo.title) · \(exercises.count) ejercicio(s)"
        }
        return exercises.isEmpty ? "" : "\(exercises.count) ejercicio(s) seleccionados"
    }

    private var totalSetsText: String {
        let total = store.items.reduce(0) { $0 + $1.sets.count }
        return "\(total) sets"
    }

    private func metaPill(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.10))
        .clipShape(Capsule())
    }

    private func iconForItem(_ item: TrainingSessionItem) -> String {
        switch item.tipo {
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

    private func setSummary(_ s: TrainingSet) -> String {
        // Mostramos lo que haya (sin forzar)
        var parts: [String] = []

        if let reps = s.reps { parts.append("\(reps) reps") }
        if let peso = s.pesoKg { parts.append(String(format: "%.1f kg", peso)) }
        if let rpe = s.rpe { parts.append("RPE \(String(format: "%.1f", rpe))") }
        if let t = s.tiempoSeg { parts.append("\(t)s") }
        if let d = s.distanciaM { parts.append("\(d)m") }

        return parts.isEmpty ? "—" : parts.joined(separator: " · ")
    }
}

import SwiftUI

struct TrainingSessionLiveView: View {

    @ObservedObject var store: TrainingSessionStore

    let mode: IniciarEntrenamientoView.Mode
    let plan: PlannedSession?
    let exercises: [Exercise]
    let accent: Color

    init(
        store: TrainingSessionStore,
        mode: IniciarEntrenamientoView.Mode,
        plan: PlannedSession?,
        exercises: [Exercise],
        accent: Color
    ) {
        self.store = store
        self.mode = mode
        self.plan = plan
        self.exercises = exercises
        self.accent = accent
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {

                header

                itemsCard

                Spacer(minLength: 30)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Sesión")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cerrar") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(store.isRunning ? "Finalizar" : "Iniciar") {
                    if store.isRunning {
                        store.stop()
                    } else {
                        store.start(title: planTitleOrDefault)
                    }
                }
                .foregroundStyle(accent)
            }
        }
        .onAppear {
            // si vienes desde “Entrenar ahora”, normalmente ya metiste ejercicios en store,
            // pero si por lo que sea no hay items, los cargamos una vez aquí.
            if store.items.isEmpty && !exercises.isEmpty {
                store.start(title: planTitleOrDefault)
                exercises.forEach { store.addExercise($0) }
            }
        }
    }

    // MARK: - UI

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.isRunning ? "En curso" : "Lista preparada")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(store.title)
                        .font(.title3.bold())
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TrainingBrand.softFill(accent))
                    Image(systemName: store.isRunning ? "timer" : "checklist")
                        .font(.headline.bold())
                        .foregroundStyle(accent)
                }
                .frame(width: 44, height: 44)
            }

            if let plan {
                Text("Plan: \(plan.nombre.isEmpty ? plan.tipo.title : plan.nombre)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Sesión libre · \(mode.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ejercicios")
                    .font(.headline.bold())
                Spacer()
                Text("\(store.items.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            if store.items.isEmpty {
                Text("No hay ejercicios en la sesión.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(store.items) { item in
                        sessionRow(item)
                    }
                }
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

    private func sessionRow(_ item: TrainingSessionItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.nombre)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Button(role: .destructive) {
                    store.removeItem(item.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // sets
            VStack(spacing: 8) {
                ForEach(Array(item.sets.enumerated()), id: \.offset) { idx, set in
                    HStack {
                        Text("Set \(idx + 1)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            store.toggleSetDone(itemId: item.id, setIndex: idx)
                        } label: {
                            Image(systemName: set.completado ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(set.completado ? accent : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    store.addSet(to: item.id)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Añadir set")
                            .font(.caption.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(accent)
                    .padding(10)
                    .background(TrainingBrand.softFill(accent))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Helpers

    private var planTitleOrDefault: String {
        if let plan {
            let t = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? "Sesión" : t
        }
        return "Sesión"
    }
}

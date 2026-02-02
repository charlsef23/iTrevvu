import SwiftUI

struct TrainingSessionLiveView: View {

    @ObservedObject var store: TrainingSessionStore

    let mode: IniciarEntrenamientoView.Mode
    let plan: PlannedSession?
    let exercises: [Exercise]
    let accent: Color

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
                        Task { await store.finish() }
                    } else {
                        Task { await startAndSeedIfNeeded() }
                    }
                }
                .foregroundStyle(accent)
            }
        }
        .task {
            // Si vienes desde “Entrenar ahora”, normalmente ya cargaste ejercicios en el store.
            // Pero si no hay items, arrancamos + sembramos una vez.
            if store.items.isEmpty && !exercises.isEmpty {
                await startAndSeedIfNeeded()
            }
        }
    }

    // MARK: - Arranque + seed

    private func startAndSeedIfNeeded() async {
        // 1) start sesión en DB + store
        await store.start(
            tipo: sessionTypeForModeOrPlan(),
            planSesionId: plan?.id,
            title: planTitleOrDefault
        )

        // 2) si después de arrancar sigue vacío, sembramos ejercicios
        guard store.items.isEmpty else { return }

        for ex in exercises {
            await store.addExercise(ex)
        }
    }

    private func sessionTypeForModeOrPlan() -> TrainingSessionType {
        if let planTipo = plan?.tipo {
            return planTipo
        }
        switch mode {
        case .gimnasio: return .gimnasio
        case .cardio: return .cardio
        case .movilidad: return .movilidad
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
                        .lineLimit(1)
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
                let t = plan.nombre.trimmingCharacters(in: .whitespacesAndNewlines)
                Text("Plan: \(t.isEmpty ? plan.tipo.title : t)")
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
                // ✅ antes: item.nombre (no existe)
                Text(item.nombreSnapshot)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Spacer()

                // 🔸 Por ahora borrado SOLO local (si quieres borrado en DB, añadimos endpoint en service)
                Button(role: .destructive) {
                    withAnimation(.snappy(duration: 0.2)) {
                        store.items.removeAll { $0.id == item.id }
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Sets
            VStack(spacing: 8) {
                ForEach(Array(item.sets.enumerated()), id: \.element.id) { idx, set in
                    HStack {
                        Text("Set \(idx + 1)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            // toggle local + sync a Supabase
                            toggleSet(itemId: item.id, setId: set.id)
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
                    Task { await store.addSet(to: item.id) }
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

    private func toggleSet(itemId: UUID, setId: UUID) {
        guard let itemIndex = store.items.firstIndex(where: { $0.id == itemId }) else { return }
        guard let setIndex = store.items[itemIndex].sets.firstIndex(where: { $0.id == setId }) else { return }

        let current = store.items[itemIndex].sets[setIndex]
        let newDone = !current.completado

        // ✅ UI inmediata
        store.items[itemIndex].sets[setIndex].completado = newDone

        // ✅ sync DB (sin rpe)
        Task {
            await store.updateSet(
                setLocalId: setId,
                reps: current.reps,
                pesoKg: current.pesoKg,
                tiempoSeg: current.tiempoSeg,
                distanciaM: current.distanciaM,
                completado: newDone
            )
        }
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

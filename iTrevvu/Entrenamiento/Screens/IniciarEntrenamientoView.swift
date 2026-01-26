import SwiftUI

struct IniciarEntrenamientoView: View {

    let plan: TrainingPlan?

    init(plan: TrainingPlan? = nil) {
        self.plan = plan
    }

    enum Mode: String, CaseIterable, Identifiable {
        case gimnasio = "Gimnasio"
        case cardio = "Cardio"
        case movilidad = "Movilidad"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .gimnasio

    // ✅ FIX: ya no recibe client
    @StateObject private var exerciseStore = ExerciseStore()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {

                if let plan {
                    SportHeroCard(
                        title: "Plan de hoy",
                        subtitle: plan.kind == .rutina
                            ? (plan.routineTitle ?? "Rutina")
                            : plan.kind.title,
                        icon: "checkmark.seal.fill",
                        accent: accentForPlan(plan)
                    )
                }

                modePicker
                quickActions
                trainingPlaceholder

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Entrenar")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .task {
            // ✅ opcional: precarga una categoría para que la biblioteca vaya “instant”
            await exerciseStore.load(type: .fuerza)
        }
        .onAppear {
            if let plan { mode = map(plan.kind) }
        }
    }

    // MARK: - UI

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Modo")
                .font(.headline.bold())

            HStack(spacing: 10) {
                ModeChip(title: "Gimnasio", isOn: mode == .gimnasio, accent: TrainingBrand.action) {
                    mode = .gimnasio
                }
                ModeChip(title: "Cardio", isOn: mode == .cardio, accent: TrainingBrand.cardio) {
                    mode = .cardio
                }
                ModeChip(title: "Movilidad", isOn: mode == .movilidad, accent: TrainingBrand.mobility) {
                    mode = .movilidad
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

    private var quickActions: some View {
        VStack(spacing: 10) {

            NavigationLink {
                // ✅ Aquí puedes cambiar a ExerciseLibraryHubView si quieres el grid de 9 tipos
                ExerciseLibraryHubView()
                    .environmentObject(exerciseStore)
            } label: {
                ActionRow(
                    title: "Biblioteca de ejercicios",
                    subtitle: "Busca, filtra y favoritos",
                    icon: "square.grid.2x2.fill",
                    accent: accentForMode(mode)
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                Text("Comenzar sesión (pendiente)")
                    .foregroundStyle(.secondary)
                    .padding()
                    .navigationTitle("Sesión")
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                ActionRow(
                    title: "Empezar ahora",
                    subtitle: "Inicia sesión rápida",
                    icon: "play.fill",
                    accent: accentForMode(mode)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var trainingPlaceholder: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sesión")
                .font(.headline.bold())

            Text("Aquí va tu flujo de entrenamiento (sets, temporizador, descanso, etc.).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func map(_ kind: TrainingPlanKind) -> Mode {
        switch kind {
        case .gimnasio, .rutina: return .gimnasio
        case .cardio: return .cardio
        case .movilidad: return .movilidad
        }
    }

    private func accentForPlan(_ plan: TrainingPlan) -> Color {
        switch plan.kind {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        case .rutina: return TrainingBrand.custom
        }
    }

    private func accentForMode(_ m: Mode) -> Color {
        switch m {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        }
    }
}

// MARK: - Small UI components

private struct ModeChip: View {
    let title: String
    let isOn: Bool
    let accent: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isOn ? .white : .primary)
                .padding(.vertical, 9)
                .padding(.horizontal, 12)
                .background(Capsule().fill(isOn ? accent : Color.gray.opacity(0.10)))
        }
        .buttonStyle(.plain)
    }
}

private struct ActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(TrainingBrand.softFill(accent))
                Image(systemName: icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }
}

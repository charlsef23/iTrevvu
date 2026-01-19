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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if let plan {
                    SportHeroCard(
                        title: "Plan de hoy",
                        subtitle: plan.kind == .rutina ? (plan.routineTitle ?? "Rutina") : plan.kind.title,
                        icon: "checkmark.seal.fill",
                        accent: accentForPlan(plan)
                    )
                }

                // tu contenido actual...
                Text("Aquí va tu flujo de entrenamiento")
                    .foregroundStyle(.secondary)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Entrenar")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .onAppear {
            if let plan {
                mode = map(plan.kind)
            }
        }
    }

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
}

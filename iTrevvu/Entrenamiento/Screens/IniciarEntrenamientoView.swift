import SwiftUI

struct IniciarEntrenamientoView: View {

    enum Mode: String, CaseIterable, Identifiable {
        case gimnasio = "Gimnasio"
        case cardio = "Cardio"
        case movilidad = "Movilidad"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .gimnasio
    @State private var isRunning = false
    @State private var seconds = 0
    @State private var timer: Timer?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: "Iniciar entrenamiento",
                    subtitle: "Elige modo y empieza a registrar",
                    icon: "play.fill",
                    accent: accentForMode(mode)
                )

                ModePicker(mode: $mode, accent: accentForMode(mode))

                TimerCard(
                    elapsed: formatted(seconds),
                    accent: accentForMode(mode),
                    isRunning: isRunning,
                    onStartStop: { toggleTimer() },
                    onReset: { resetTimer() }
                )

                SectionHeader(title: "Accesos rápidos", actionTitle: nil, tint: nil) { }

                VStack(spacing: 12) {
                    QuickActionCard(
                        title: "Añadir ejercicio",
                        subtitle: "Series, reps, peso, RPE…",
                        icon: "plus.circle.fill",
                        accent: accentForMode(mode)
                    )

                    QuickActionCard(
                        title: "Añadir nota",
                        subtitle: "Técnica, sensaciones, objetivos",
                        icon: "pencil",
                        accent: accentForMode(mode)
                    )
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Entrenar")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .onDisappear { timer?.invalidate() }
    }

    private func accentForMode(_ mode: Mode) -> Color {
        switch mode {
        case .gimnasio: return TrainingBrand.action
        case .cardio: return TrainingBrand.cardio
        case .movilidad: return TrainingBrand.mobility
        }
    }

    private func toggleTimer() {
        isRunning.toggle()
        if isRunning {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                seconds += 1
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }

    private func resetTimer() {
        seconds = 0
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func formatted(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

private struct ModePicker: View {
    @Binding var mode: IniciarEntrenamientoView.Mode
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            ForEach(IniciarEntrenamientoView.Mode.allCases) { m in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        mode = m
                    }
                } label: {
                    Text(m.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(mode == m ? .white : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(mode == m ? accent : TrainingBrand.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(TrainingBrand.separator, lineWidth: mode == m ? 0 : 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TimerCard: View {
    let elapsed: String
    let accent: Color
    let isRunning: Bool
    let onStartStop: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Temporizador")
                    .font(.headline.bold())
                Spacer()
                Text(elapsed)
                    .font(.title2.bold())
                    .monospacedDigit()
                    .foregroundStyle(accent)
            }

            HStack(spacing: 10) {
                Button(action: onStartStop) {
                    Label(isRunning ? "Pausar" : "Iniciar", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(accent)

                Button(action: onReset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(accent)
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }
}

private struct QuickActionCard: View {
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
                Text(title).font(.headline.weight(.semibold))
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
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }
}

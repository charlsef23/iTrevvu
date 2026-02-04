import SwiftUI
import Combine

struct EntrenandoRapidoView: View {

    let type: QuickWorkoutType
    let session: QuickWorkoutSession
    @ObservedObject var store: QuickWorkoutStore

    @Environment(\.dismiss) private var dismiss

    @State private var isRunning = true
    @State private var seconds = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 14) {

            header

            Spacer()

            Text(timeString(seconds))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text("Tiempo")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    isRunning.toggle()
                } label: {
                    Label(isRunning ? "Pausar" : "Continuar",
                          systemImage: isRunning ? "pause.fill" : "play.fill")
                    .frame(maxWidth: .infinity, minHeight: 54)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    Task {
                        await store.finishSession(sessionId: session.id, seconds: seconds)
                        dismiss()
                    }
                } label: {
                    Label("Finalizar", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity, minHeight: 54)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: type.color))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(TrainingBrand.bg)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(type.nombre).font(.headline.bold())
            }
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            seconds += 1
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: type.color).opacity(0.18))
                Image(systemName: type.icono)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(hex: type.color))
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 2) {
                Text("Entrenando")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(type.nombre)
                    .font(.headline.bold())
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private func timeString(_ total: Int) -> String {
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Color HEX helper

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

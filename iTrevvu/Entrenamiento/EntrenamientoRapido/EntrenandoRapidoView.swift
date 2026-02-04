import SwiftUI
import Combine
import MapKit

struct EntrenandoRapidoView: View {

    let type: QuickWorkoutType
    let session: QuickWorkoutSession
    @ObservedObject var store: QuickWorkoutStore

    @StateObject private var vm = QuickWorkoutLiveViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {

            if !vm.isRunning {
                countdownView
            } else {
                liveMetricsView
            }

            Spacer()

            Button(role: .destructive) {
                Task {
                    vm.stop()
                    await store.finishSession(
                        sessionId: session.id,
                        seconds: vm.seconds,
                        calories: Int(vm.calories),
                        distanceM: Float(vm.distance)
                    )
                    dismiss()
                }
            } label: {
                Text("Finalizar")
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(type.uiColor)                 // ✅ sin hex
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle(type.nombre)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.startCountdown() }
    }

    private var countdownView: some View {
        Text("\(vm.countdown)")
            .font(.system(size: 96, weight: .bold))
            .foregroundStyle(type.uiColor)      // ✅ sin hex
            .padding(.top, 80)
    }

    private var liveMetricsView: some View {
        VStack(spacing: 20) {
            Text(time(vm.seconds))
                .font(.system(size: 56, weight: .bold))
                .monospacedDigit()

            HStack(spacing: 20) {
                metric("🔥", "\(Int(vm.calories)) kcal")
                metric("📏", "\(Int(vm.distance)) m")
                metric("👣", "\(vm.steps)")
            }
        }
        .padding(.top, 40)
    }

    private func metric(_ icon: String, _ value: String) -> some View {
        VStack {
            Text(icon).font(.largeTitle)
            Text(value).font(.headline)
        }
    }

    private func time(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}

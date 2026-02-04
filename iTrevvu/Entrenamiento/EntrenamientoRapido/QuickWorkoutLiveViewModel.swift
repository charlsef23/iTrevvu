import Foundation
import Combine

@MainActor
final class QuickWorkoutLiveViewModel: ObservableObject {

    @Published var countdown: Int = 3
    @Published var isRunning: Bool = false
    @Published var seconds: Int = 0

    @Published var calories: Double = 0
    @Published var distance: Double = 0
    @Published var steps: Int = 0
    @Published var heartRate: Int = 0

    private var countdownCancellable: AnyCancellable?
    private var workoutCancellable: AnyCancellable?

    func startCountdown() {
        stop() // limpia timers anteriores

        countdown = 3
        isRunning = false

        // ✅ Combine timer (en main run loop) => seguro con @MainActor
        countdownCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.countdown -= 1

                if self.countdown <= 0 {
                    self.countdownCancellable?.cancel()
                    self.countdownCancellable = nil
                    self.startWorkout()
                }
            }
    }

    private func startWorkout() {
        isRunning = true

        // ✅ timer de “entreno” (demo). Luego lo sustituimos por HealthKit real.
        workoutCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.seconds += 1
                self.calories += 0.12
                self.distance += 0.8
                self.steps += 2
            }
    }

    func stop() {
        countdownCancellable?.cancel()
        countdownCancellable = nil

        workoutCancellable?.cancel()
        workoutCancellable = nil

        isRunning = false
    }
}

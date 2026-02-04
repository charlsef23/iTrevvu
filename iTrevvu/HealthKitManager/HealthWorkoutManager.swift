import Foundation
import HealthKit
import Combine

final class HealthWorkoutManager: ObservableObject {

    @Published private(set) var isAuthorized = false

    // Live metrics
    @Published private(set) var heartRate: Double = 0          // bpm
    @Published private(set) var activeEnergy: Double = 0       // kcal
    @Published private(set) var steps: Double = 0              // count

    private let healthStore = HKHealthStore()

    private var hrQuery: HKQuery?
    private var energyQuery: HKQuery?
    private var stepsQuery: HKQuery?

    // ✅ Evitamos "captured var anchor" (Swift 6)
    private var anchors: [HKQuantityTypeIdentifier: HKQueryAnchor] = [:]

    // MARK: - Auth

    @MainActor
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let read: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: read)
            isAuthorized = true
        } catch {
            isAuthorized = false
        }
    }

    // MARK: - Live

    func startLive() {
        stopLive()

        startAnchoredSum(
            identifier: .activeEnergyBurned,
            unit: .kilocalorie(),
            onUpdateMain: { [weak self] value in self?.activeEnergy = value },
            store: &energyQuery
        )

        startAnchoredSum(
            identifier: .stepCount,
            unit: .count(),
            onUpdateMain: { [weak self] value in self?.steps = value },
            store: &stepsQuery
        )

        startAnchoredMostRecent(
            identifier: .heartRate,
            unit: HKUnit(from: "count/min"),
            onUpdateMain: { [weak self] value in self?.heartRate = value },
            store: &hrQuery
        )
    }

    func stopLive() {
        if let q = hrQuery { healthStore.stop(q) }
        if let q = energyQuery { healthStore.stop(q) }
        if let q = stepsQuery { healthStore.stop(q) }

        hrQuery = nil
        energyQuery = nil
        stepsQuery = nil
    }

    // MARK: - Queries

    private func startAnchoredSum(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        onUpdateMain: @escaping (Double) -> Void,
        store: inout HKQuery?
    ) {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return }

        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: nil, options: .strictStartDate)

        let anchor = anchors[identifier]

        let query = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) {
            [weak self] _, samples, _, newAnchor, _ in
            guard let self else { return }

            // ✅ Swift 6 safe: no captured var mutation
            if let newAnchor { self.anchors[identifier] = newAnchor }

            let total = Self.sum(samples, unit: unit)

            Task { @MainActor in
                onUpdateMain(total)
            }
        }

        query.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
            guard let self else { return }
            if let newAnchor { self.anchors[identifier] = newAnchor }

            let total = Self.sum(samples, unit: unit)

            Task { @MainActor in
                onUpdateMain(total)
            }
        }

        store = query
        healthStore.execute(query)
    }

    private func startAnchoredMostRecent(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        onUpdateMain: @escaping (Double) -> Void,
        store: inout HKQuery?
    ) {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return }

        let start = Date().addingTimeInterval(-60 * 60) // última hora
        let predicate = HKQuery.predicateForSamples(withStart: start, end: nil, options: .strictStartDate)

        let anchor = anchors[identifier]

        let query = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) {
            [weak self] _, samples, _, newAnchor, _ in
            guard let self else { return }
            if let newAnchor { self.anchors[identifier] = newAnchor }

            let value = Self.mostRecent(samples, unit: unit)

            Task { @MainActor in
                onUpdateMain(value)
            }
        }

        query.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
            guard let self else { return }
            if let newAnchor { self.anchors[identifier] = newAnchor }

            let value = Self.mostRecent(samples, unit: unit)

            Task { @MainActor in
                onUpdateMain(value)
            }
        }

        store = query
        healthStore.execute(query)
    }

    // MARK: - Pure helpers (NO actor)

    private static func sum(_ samples: [HKSample]?, unit: HKUnit) -> Double {
        guard let qs = samples as? [HKQuantitySample] else { return 0 }
        return qs.reduce(0) { $0 + $1.quantity.doubleValue(for: unit) }
    }

    private static func mostRecent(_ samples: [HKSample]?, unit: HKUnit) -> Double {
        guard let qs = samples as? [HKQuantitySample] else { return 0 }
        let latest = qs.max(by: { $0.endDate < $1.endDate })
        return latest?.quantity.doubleValue(for: unit) ?? 0
    }
}

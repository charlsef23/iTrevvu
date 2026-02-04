import SwiftUI
import HealthKit

extension QuickWorkoutType {

    var isCardio: Bool {
        tipo.contains("andar") || tipo.contains("correr") || tipo.contains("cinta")
    }

    var hkActivity: HKWorkoutActivityType {
        if tipo == "fuerza" { return .traditionalStrengthTraining }
        if tipo == "movilidad" { return .yoga }
        if tipo.contains("andar") { return .walking }
        if tipo.contains("correr") { return .running }
        return .other
    }

    /// ✅ Color SwiftUI normal (sin hex)
    var uiColor: Color {
        if tipo == "fuerza" { return .blue }
        if tipo == "movilidad" { return .purple }

        if tipo.contains("andar") { return .green }
        if tipo.contains("correr") { return .orange }

        if tipo.contains("cinta") { return .teal }

        return .accentColor
    }
}

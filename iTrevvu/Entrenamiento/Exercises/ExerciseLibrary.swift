import Foundation

enum ExerciseLibrary {

    static var base: [Exercise] {
        var e: [Exercise] = []

        // MARK: - Pecho
        e += [
            .init(name: "Press banca", category: .fuerza, primary: .pecho, secondary: [.triceps, .hombro], equipment: [.barra, .banco], pattern: .empuje, defaultRepRange: "5–10"),
            .init(name: "Press banca inclinado", category: .fuerza, primary: .pecho, secondary: [.hombro, .triceps], equipment: [.barra, .banco], pattern: .empuje, defaultRepRange: "6–12"),
            .init(name: "Press mancuernas", category: .fuerza, primary: .pecho, secondary: [.triceps, .hombro], equipment: [.mancuernas, .banco], pattern: .empuje, defaultRepRange: "8–12"),
            .init(name: "Fondos en paralelas", category: .fuerza, primary: .pecho, secondary: [.triceps, .hombro], equipment: [.pesoCorporal], pattern: .empuje, defaultRepRange: "6–15", isBodyweight: true),
            .init(name: "Flexiones", category: .fuerza, primary: .pecho, secondary: [.triceps, .hombro, .core], equipment: [.pesoCorporal], pattern: .empuje, defaultRepRange: "10–25", isBodyweight: true),
            .init(name: "Aperturas en polea", category: .fuerza, primary: .pecho, secondary: [], equipment: [.polea], pattern: .aislamiento, defaultRepRange: "10–15"),
            .init(name: "Pec deck", category: .fuerza, primary: .pecho, secondary: [], equipment: [.maquina], pattern: .aislamiento, defaultRepRange: "10–15")
        ]

        // MARK: - Espalda
        e += [
            .init(name: "Dominadas", category: .fuerza, primary: .espalda, secondary: [.biceps, .core], equipment: [.pesoCorporal], pattern: .tiron, defaultRepRange: "5–12", isBodyweight: true),
            .init(name: "Jalón al pecho", category: .fuerza, primary: .espalda, secondary: [.biceps], equipment: [.polea], pattern: .tiron, defaultRepRange: "8–12"),
            .init(name: "Remo con barra", category: .fuerza, primary: .espalda, secondary: [.biceps, .core], equipment: [.barra], pattern: .tiron, defaultRepRange: "6–10"),
            .init(name: "Remo con mancuerna", category: .fuerza, primary: .espalda, secondary: [.biceps], equipment: [.mancuernas, .banco], pattern: .tiron, defaultRepRange: "8–12", isUnilateral: true),
            .init(name: "Remo en máquina", category: .fuerza, primary: .espalda, secondary: [.biceps], equipment: [.maquina], pattern: .tiron, defaultRepRange: "8–12"),
            .init(name: "Face pull", category: .fuerza, primary: .hombro, secondary: [.espalda], equipment: [.polea], pattern: .tiron, defaultRepRange: "12–20")
        ]

        // MARK: - Hombro
        e += [
            .init(name: "Press militar", category: .fuerza, primary: .hombro, secondary: [.triceps, .core], equipment: [.barra], pattern: .empuje, defaultRepRange: "5–10"),
            .init(name: "Press mancuernas sentado", category: .fuerza, primary: .hombro, secondary: [.triceps], equipment: [.mancuernas, .banco], pattern: .empuje, defaultRepRange: "8–12"),
            .init(name: "Elevaciones laterales", category: .fuerza, primary: .hombro, secondary: [], equipment: [.mancuernas], pattern: .aislamiento, defaultRepRange: "12–20"),
            .init(name: "Pájaros (deltoide posterior)", category: .fuerza, primary: .hombro, secondary: [.espalda], equipment: [.mancuernas], pattern: .aislamiento, defaultRepRange: "12–20")
        ]

        // MARK: - Brazos
        e += [
            .init(name: "Curl bíceps barra", category: .fuerza, primary: .biceps, secondary: [], equipment: [.barra], pattern: .aislamiento, defaultRepRange: "8–12"),
            .init(name: "Curl bíceps mancuernas", category: .fuerza, primary: .biceps, secondary: [], equipment: [.mancuernas], pattern: .aislamiento, defaultRepRange: "8–12", isUnilateral: true),
            .init(name: "Curl martillo", category: .fuerza, primary: .biceps, secondary: [], equipment: [.mancuernas], pattern: .aislamiento, defaultRepRange: "10–15"),
            .init(name: "Extensión tríceps polea", category: .fuerza, primary: .triceps, secondary: [], equipment: [.polea], pattern: .aislamiento, defaultRepRange: "10–15"),
            .init(name: "Fondos tríceps en banco", category: .fuerza, primary: .triceps, secondary: [.hombro], equipment: [.banco, .pesoCorporal], pattern: .empuje, defaultRepRange: "10–20", isBodyweight: true)
        ]

        // MARK: - Pierna
        e += [
            .init(name: "Sentadilla", category: .fuerza, primary: .cuadriceps, secondary: [.gluteo, .core], equipment: [.barra], pattern: .sentadilla, defaultRepRange: "5–10"),
            .init(name: "Sentadilla frontal", category: .fuerza, primary: .cuadriceps, secondary: [.core], equipment: [.barra], pattern: .sentadilla, defaultRepRange: "5–8"),
            .init(name: "Prensa", category: .fuerza, primary: .cuadriceps, secondary: [.gluteo], equipment: [.maquina], pattern: .sentadilla, defaultRepRange: "10–15"),
            .init(name: "Zancadas caminando", category: .fuerza, primary: .gluteo, secondary: [.cuadriceps], equipment: [.mancuernas], pattern: .sentadilla, defaultRepRange: "10–16", isUnilateral: true),
            .init(name: "Peso muerto rumano", category: .fuerza, primary: .femoral, secondary: [.gluteo, .espalda], equipment: [.barra], pattern: .bisagra, defaultRepRange: "6–12"),
            .init(name: "Curl femoral", category: .fuerza, primary: .femoral, secondary: [], equipment: [.maquina], pattern: .aislamiento, defaultRepRange: "10–15"),
            .init(name: "Hip thrust", category: .fuerza, primary: .gluteo, secondary: [.femoral], equipment: [.barra, .banco], pattern: .bisagra, defaultRepRange: "8–12"),
            .init(name: "Gemelo de pie", category: .fuerza, primary: .gemelo, secondary: [], equipment: [.maquina], pattern: .aislamiento, defaultRepRange: "10–20")
        ]

        // MARK: - Core
        e += [
            .init(name: "Plancha", category: .fuerza, primary: .core, secondary: [], equipment: [.pesoCorporal], pattern: .core, defaultRepRange: "30–90s", isBodyweight: true),
            .init(name: "Elevación de piernas", category: .fuerza, primary: .core, secondary: [], equipment: [.pesoCorporal], pattern: .core, defaultRepRange: "8–15", isBodyweight: true),
            .init(name: "Crunch", category: .fuerza, primary: .core, secondary: [], equipment: [.pesoCorporal], pattern: .core, defaultRepRange: "12–25", isBodyweight: true)
        ]

        // MARK: - Cardio (genérico)
        e += [
            .init(name: "Cinta (trote)", category: .cardio, primary: .cardio, secondary: [], equipment: [.cardioMachine], pattern: .locomocion, defaultRepRange: "20–45 min"),
            .init(name: "Bicicleta estática", category: .cardio, primary: .cardio, secondary: [], equipment: [.cardioMachine], pattern: .locomocion, defaultRepRange: "20–60 min"),
            .init(name: "Remo (ergómetro)", category: .cardio, primary: .cardio, secondary: [.espalda, .core], equipment: [.cardioMachine], pattern: .locomocion, defaultRepRange: "10–30 min")
        ]

        // MARK: - Movilidad (genérico)
        e += [
            .init(name: "Movilidad cadera", category: .movilidad, primary: .movilidad, secondary: [], equipment: [.pesoCorporal], pattern: .movilidad, defaultRepRange: "5–10 min", isBodyweight: true),
            .init(name: "Movilidad tobillo", category: .movilidad, primary: .movilidad, secondary: [], equipment: [.pesoCorporal], pattern: .movilidad, defaultRepRange: "5–10 min", isBodyweight: true),
            .init(name: "Estiramiento isquios", category: .movilidad, primary: .movilidad, secondary: [], equipment: [.banda], pattern: .movilidad, defaultRepRange: "2–4 min")
        ]

        return e
    }
}

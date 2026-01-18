import SwiftUI

enum TrainingBrand {

    // MARK: - Base (neutros)
    static let bg = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemBackground)
    static let separator = Color.gray.opacity(0.14)
    static let muted = Color.secondary
    static let primary = Color.primary

    // MARK: - Marca y acentos (pocos, con significado)
    static let action = Color.red          // CTA / marca
    static let cardio = Color.orange       // energía
    static let mobility = Color.green      // recuperación
    static let stats = Color.blue          // datos
    static let custom = Color.purple       // personalización

    // MARK: - Layout
    static let corner: CGFloat = 22
    static let cornerSmall: CGFloat = 16

    // Sombra mínima (para que no “cante”)
    static let shadow = Color.black.opacity(0.08)

    static func softFill(_ tint: Color) -> Color { tint.opacity(0.10) }
    static func softStroke(_ tint: Color) -> Color { tint.opacity(0.18) }
}

import SwiftUI

enum TrainingBrand {
    static let bg = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let separator = Color.black.opacity(0.08)
    static let corner: CGFloat = 18

    static let action = Color.red
    static let cardio = Color.orange
    static let mobility = Color.blue
    static let custom = Color.purple
    static let stats = Color.pink

    static func softFill(_ c: Color) -> Color { c.opacity(0.12) }
}

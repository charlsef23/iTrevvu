import SwiftUI

enum NutritionBrand {
    static let red = Color.red
    static let bg = Color(.systemBackground)
    static let card = Color(.secondarySystemBackground)
    static let subtle = Color(.secondaryLabel)

    static let corner: CGFloat = 22
    static let pad: CGFloat = 14

    static func cardStyle() -> some ShapeStyle { card }
}

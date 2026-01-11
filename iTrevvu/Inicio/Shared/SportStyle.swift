import SwiftUI

enum SportStyle {
    static func tint(for sport: SportType) -> Color {
        switch sport {
        case .gym: return .red
        case .running: return .orange
        case .cycling: return .green
        case .swimming: return .blue
        case .football: return .teal
        case .basketball: return .purple
        case .yoga: return .pink
        case .hiit: return .red
        }
    }

    static func icon(for sport: SportType) -> String {
        switch sport {
        case .gym: return "dumbbell.fill"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .football: return "sportscourt"
        case .basketball: return "basketball.fill"
        case .yoga: return "figure.mind.and.body"
        case .hiit: return "flame.fill"
        }
    }

    static func background(for sport: SportType) -> LinearGradient {
        let c = tint(for: sport)
        return LinearGradient(
            colors: [c.opacity(0.22), c.opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

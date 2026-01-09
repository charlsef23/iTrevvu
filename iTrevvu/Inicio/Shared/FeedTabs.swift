import Foundation

enum FeedTab: String, CaseIterable, Identifiable {
    case forYou = "Para ti"
    case following = "Siguiendo"
    case clips = "Clips" // 👈 nombre distinto a “Reels”

    var id: String { rawValue }
}

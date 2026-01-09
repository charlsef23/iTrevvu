import Foundation

enum FeedTimeFormatter {
    static func relative(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "ahora" }
        let minutes = seconds / 60
        if minutes < 60 { return "hace \(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "hace \(hours)h" }
        let days = hours / 24
        return "hace \(days)d"
    }
}

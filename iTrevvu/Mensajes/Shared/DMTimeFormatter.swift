import Foundation

enum DMTimeFormatter {
    static func time(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "es_ES")
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }

    static func relative(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "ahora" }
        let minutes = seconds / 60
        if minutes < 60 { return "hace \(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "hace \(hours)h" }
        return "hace \(hours / 24)d"
    }
}

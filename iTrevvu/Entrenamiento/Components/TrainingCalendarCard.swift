import SwiftUI

struct TrainingCalendarCard: View {

    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    private let accent = TrainingBrand.stats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Calendario")
                        .font(.headline.bold())
                    Text(formattedMonth(selectedDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Button("Hoy") {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        selectedDate = .now
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(accent)
            }

            HStack(spacing: 8) {
                ForEach(weekDays(for: selectedDate), id: \.self) { day in
                    DayPill(
                        date: day,
                        isSelected: isSameDay(day, selectedDate),
                        isToday: isSameDay(day, .now),
                        accent: accent
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            selectedDate = day
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 7, y: 4)
    }

    private func weekDays(for date: Date) -> [Date] {
        var cal = calendar
        cal.firstWeekday = 2 // lunes
        let start = cal.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    private func formattedMonth(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "es_ES")
        fmt.dateFormat = "LLLL yyyy"
        return fmt.string(from: date).capitalized
    }
}

private struct DayPill: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let accent: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(weekdayLetter(date))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .secondary)

            Text(dayNumber(date))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isSelected ? accent : .clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    isToday && !isSelected ? accent.opacity(0.45) : Color.gray.opacity(0.15),
                    lineWidth: 1
                )
        )
    }

    private func weekdayLetter(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "es_ES")
        fmt.dateFormat = "EEEEE"
        return fmt.string(from: date).uppercased()
    }

    private func dayNumber(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "es_ES")
        fmt.dateFormat = "d"
        return fmt.string(from: date)
    }
}

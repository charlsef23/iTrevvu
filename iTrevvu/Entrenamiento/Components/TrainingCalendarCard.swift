import SwiftUI

enum CalendarDisplayMode: String {
    case week
    case month
}

struct TrainingCalendarCard: View {

    @Binding var selectedDate: Date
    @Binding var mode: CalendarDisplayMode

    @EnvironmentObject private var planner: TrainingPlannerStore

    private let cal: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 2 // lunes
        return c
    }()

    @State private var monthCursor: Date = .now
    @State private var showPlanSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            header

            if mode == .week {
                weekRow
            } else {
                monthGrid
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: mode)
        .sheet(isPresented: $showPlanSheet) {
            PlanTrainingSheet(date: selectedDate, existing: planner.plan(for: selectedDate))
                .environmentObject(planner)
        }
        .onAppear {
            monthCursor = selectedDate
        }
        .onChange(of: selectedDate) { _, newValue in
            if mode == .month {
                monthCursor = newValue
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Calendario")
                    .font(.headline.bold())

                Text(formattedMonth(monthCursor))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showPlanSheet = true
            } label: {
                Text(planner.plan(for: selectedDate) == nil ? "Planificar" : "Editar")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(TrainingBrand.stats)
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    mode = (mode == .week) ? .month : .week
                }
            } label: {
                Image(systemName: mode == .week ? "rectangle.grid.2x2" : "rectangle.compress.vertical")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - WEEK

    private var weekRow: some View {
        HStack(spacing: 8) {
            ForEach(weekDays(for: selectedDate), id: \.self) { day in
                DayPill(
                    date: day,
                    isSelected: isSameDay(day, selectedDate),
                    isToday: isSameDay(day, .now),
                    hasPlan: planner.plan(for: day) != nil
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        selectedDate = day
                    }
                }
            }
        }
    }

    // MARK: - MONTH

    private var monthGrid: some View {
        VStack(spacing: 10) {

            HStack {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        monthCursor = cal.date(byAdding: .month, value: -1, to: monthCursor) ?? monthCursor
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Hoy") {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        selectedDate = .now
                        monthCursor = .now
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TrainingBrand.stats)
                .buttonStyle(.plain)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        monthCursor = cal.date(byAdding: .month, value: 1, to: monthCursor) ?? monthCursor
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Header L M X J V S D (lunes primero)
            HStack(spacing: 8) {
                ForEach(weekdaySymbolsMondayFirst(), id: \.self) { s in
                    Text(s)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            let days = monthDays(for: monthCursor)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { day in
                    MonthDayCell(
                        date: day,
                        isInDisplayedMonth: cal.isDate(day, equalTo: monthCursor, toGranularity: .month),
                        isSelected: isSameDay(day, selectedDate),
                        isToday: isSameDay(day, .now),
                        hasPlan: planner.plan(for: day) != nil
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            selectedDate = day
                        }
                    }
                }
            }
        }
    }

    // MARK: - Date Helpers

    private func weekDays(for date: Date) -> [Date] {
        let start = cal.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private func monthDays(for date: Date) -> [Date] {
        // 6x7 = 42 días para grid estable
        guard let monthInterval = cal.dateInterval(of: .month, for: date) else { return [] }
        let firstOfMonth = monthInterval.start

        // weekday: 1..7 (domingo..sábado en muchos locales)
        let weekday = cal.component(.weekday, from: firstOfMonth)

        // shift calculado para firstWeekday=2 (lunes)
        let shift = (weekday - cal.firstWeekday + 7) % 7
        let gridStart = cal.date(byAdding: .day, value: -shift, to: firstOfMonth) ?? firstOfMonth

        return (0..<42).compactMap { cal.date(byAdding: .day, value: $0, to: gridStart) }
    }

    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        cal.isDate(a, inSameDayAs: b)
    }

    private func formattedMonth(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "es_ES")
        fmt.dateFormat = "LLLL yyyy"
        return fmt.string(from: date).capitalized
    }

    private func weekdaySymbolsMondayFirst() -> [String] {
        // Forzamos orden L M X J V S D en español (super estable)
        return ["L", "M", "X", "J", "V", "S", "D"]
    }
}

// MARK: - Day UI

private struct DayPill: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasPlan: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(weekdayLetter(date))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .secondary)

            ZStack(alignment: .bottom) {
                Text(dayNumber(date))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(isSelected ? .white : .primary)

                if hasPlan && !isSelected {
                    Circle()
                        .fill(TrainingBrand.stats)
                        .frame(width: 5, height: 5)
                        .offset(y: 10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isSelected ? TrainingBrand.stats : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    isToday && !isSelected ? TrainingBrand.stats.opacity(0.45) : Color.gray.opacity(0.15),
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

private struct MonthDayCell: View {
    let date: Date
    let isInDisplayedMonth: Bool
    let isSelected: Bool
    let isToday: Bool
    let hasPlan: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? TrainingBrand.stats : .clear)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isToday && !isSelected ? TrainingBrand.stats.opacity(0.45) : Color.gray.opacity(0.12),
                    lineWidth: 1
                )

            VStack(spacing: 6) {
                Text("\(dayNum(date))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : (isInDisplayedMonth ? .primary : .secondary.opacity(0.6)))

                if hasPlan && !isSelected {
                    Circle()
                        .fill(TrainingBrand.stats)
                        .frame(width: 5, height: 5)
                } else {
                    Spacer().frame(height: 5)
                }
            }
            .padding(.vertical, 8)
        }
        .frame(height: 42)
        .opacity(isInDisplayedMonth ? 1.0 : 0.55)
    }

    private func dayNum(_ d: Date) -> Int {
        Calendar.current.component(.day, from: d)
    }
}

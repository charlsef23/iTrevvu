import SwiftUI

struct WorkoutPostView: View {
    let text: String?
    let workout: WorkoutSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            if let text, !text.isEmpty {
                Text(text)
                    .font(.subheadline)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(SportStyle.tint(for: workout.sport).opacity(0.14))
                        Image(systemName: SportStyle.icon(for: workout.sport))
                            .foregroundStyle(SportStyle.tint(for: workout.sport))
                            .font(.headline.weight(.bold))
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.title)
                            .font(.headline.bold())
                        Text("\(workout.sport.rawValue) · \(workout.durationMinutes) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let kcal = workout.calories {
                        Text("\(kcal) kcal")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(SportStyle.tint(for: workout.sport))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(SportStyle.tint(for: workout.sport).opacity(0.10))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 10) {
                    MetricChip(text: workout.mainMetric, tint: SportStyle.tint(for: workout.sport))
                    MetricChip(text: workout.secondaryMetric, tint: SportStyle.tint(for: workout.sport))
                }
            }
            .padding(14)
            .background(SportStyle.background(for: workout.sport))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(SportStyle.tint(for: workout.sport).opacity(0.18), lineWidth: 1)
            )
        }
        .padding(.top, 6)
    }
}

private struct MetricChip: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(tint.opacity(0.10))
            .clipShape(Capsule())
    }
}

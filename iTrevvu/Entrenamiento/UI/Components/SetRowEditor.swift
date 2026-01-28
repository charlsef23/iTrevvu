import SwiftUI

struct SetRowEditor: View {

    let setNumber: Int
    let accent: Color

    @Binding var reps: Int
    @Binding var peso: Double
    @Binding var rpe: Double
    @Binding var isDone: Bool

    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {

            Text("Set \(setNumber)")
                .font(.caption.weight(.semibold))
                .frame(width: 56, alignment: .leading)
                .foregroundStyle(.secondary)

            NumberField(title: "Reps", value: $reps, width: 64)
            NumberDoubleField(title: "Kg", value: $peso, width: 72)
            NumberDoubleField(title: "RPE", value: $rpe, width: 72)

            Spacer()

            Button {
                isDone.toggle()
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isDone ? accent : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }
}

private struct NumberField: View {
    let title: String
    @Binding var value: Int
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            TextField("", value: $value, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.plain)
        }
        .frame(width: width)
    }
}

private struct NumberDoubleField: View {
    let title: String
    @Binding var value: Double
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            TextField("", value: $value, format: .number.precision(.fractionLength(1)))
                .keyboardType(.decimalPad)
                .textFieldStyle(.plain)
        }
        .frame(width: width)
    }
}

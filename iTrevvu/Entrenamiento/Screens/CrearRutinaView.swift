import SwiftUI

struct CrearRutinaView: View {

    private let accent = TrainingBrand.custom

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var note: String = ""
    @State private var daysPerWeek: Int = 3
    @State private var estimatedMinutes: Int = 45

    @State private var exercises: [String] = ["Press banca", "Dominadas", "Sentadilla"]
    @State private var newExercise: String = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: "Nueva rutina",
                    subtitle: "Crea un plan reusable y compártelo",
                    icon: "wand.and.stars",
                    accent: accent
                )

                FormCard(title: "Detalles", accent: accent) {
                    LabeledTextField(title: "Nombre", placeholder: "Ej: Torso/Pierna", text: $name)
                    LabeledTextField(title: "Notas", placeholder: "Objetivo, técnica, etc.", text: $note)

                    StepRow(title: "Días/semana", value: "\(daysPerWeek)", accent: accent) {
                        Stepper("", value: $daysPerWeek, in: 1...7).labelsHidden()
                    }
                    StepRow(title: "Duración", value: "\(estimatedMinutes) min", accent: accent) {
                        Stepper("", value: $estimatedMinutes, in: 10...180, step: 5).labelsHidden()
                    }
                }

                FormCard(title: "Ejercicios", accent: accent) {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            TextField("Añadir ejercicio…", text: $newExercise)
                                .textInputAutocapitalization(.sentences)
                                .autocorrectionDisabled()

                            Button {
                                let t = newExercise.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !t.isEmpty else { return }
                                exercises.append(t)
                                newExercise = ""
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(accent)
                        }

                        ForEach(exercises.indices, id: \.self) { i in
                            HStack {
                                Text(exercises[i])
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Button {
                                    exercises.remove(at: i)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(12)
                            .background(TrainingBrand.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(TrainingBrand.separator, lineWidth: 1)
                            )
                        }
                    }
                }

                Button {
                    // Aquí después lo guardas en Supabase
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Guardar rutina")
                            .font(.headline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Crear rutina")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }
}

private struct FormCard<Content: View>: View {
    let title: String
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline.bold())
                Spacer()
                Circle()
                    .fill(accent.opacity(0.25))
                    .frame(width: 10, height: 10)
            }

            content
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
        .shadow(color: TrainingBrand.shadow, radius: 6, y: 4)
    }
}

private struct LabeledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

private struct StepRow<Control: View>: View {
    let title: String
    let value: String
    let accent: Color
    @ViewBuilder let control: Control

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(value).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            control
                .tint(accent)
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

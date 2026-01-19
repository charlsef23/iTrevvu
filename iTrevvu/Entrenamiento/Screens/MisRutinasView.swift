import SwiftUI

struct MisRutinasView: View {

    private let accent = TrainingBrand.custom

    private struct Routine: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let tag: String?
    }

    @State private var query: String = ""
    @State private var routines: [Routine] = [
        .init(title: "Fuerza · Parte superior", subtitle: "6 ejercicios · 45 min", tag: "Recomendada"),
        .init(title: "Hipertrofia · Pierna", subtitle: "7 ejercicios · 55 min", tag: "Popular"),
        .init(title: "Full Body · Express", subtitle: "5 ejercicios · 30 min", tag: "Rápida"),
        .init(title: "Cardio · Intervalos", subtitle: "20 min · HIIT", tag: "Cardio")
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: "Mis rutinas",
                    subtitle: "Guarda, edita y reutiliza tus planes",
                    icon: "bookmark.fill",
                    accent: accent
                )

                SearchPill(text: $query, accent: accent)

                SectionHeader(title: "Tus rutinas", actionTitle: "Crear", tint: accent) {
                    // Si quieres, aquí navegas a CrearRutinaView desde arriba
                }

                VStack(spacing: 12) {
                    ForEach(filteredRoutines) { r in
                        NavigationLink { RutinaDetalleView(title: r.title) } label: {
                            RoutineCard(title: r.title, subtitle: r.subtitle, tag: r.tag)
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink { CrearRutinaView() } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                        Text("Crear nueva rutina")
                            .font(.headline.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundStyle(accent)
                    .padding(14)
                    .background(TrainingBrand.softFill(accent))
                    .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Mis rutinas")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
    }

    private var filteredRoutines: [Routine] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return routines }
        return routines.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }
}

private struct SearchPill: View {
    @Binding var text: String
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Buscar rutina…", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }
}

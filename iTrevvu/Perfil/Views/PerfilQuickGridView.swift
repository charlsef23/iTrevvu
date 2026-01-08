import SwiftUI

struct PerfilQuickGridView: View {

    private enum Brand {
        static let red = Color.red
        static let card = Color(.secondarySystemBackground)
        static let corner: CGFloat = 18
    }

    enum Tab: String, CaseIterable, Identifiable {
        case posts = "Mis posts"
        case logros = "Logros"
        case guardados = "Guardados"
        case estadisticas = "Estadísticas"
        case entrenos = "Entrenos"
        case amigos = "Amigos"
        case retos = "Retos"
        case ajustes = "Ajustes"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .posts: return "square.grid.2x2"
            case .logros: return "trophy"
            case .guardados: return "bookmark"
            case .estadisticas: return "chart.line.uptrend.xyaxis"
            case .entrenos: return "dumbbell"
            case .amigos: return "person.2"
            case .retos: return "flag.checkered"
            case .ajustes: return "gearshape"
            }
        }

        var subtitle: String {
            switch self {
            case .posts: return "Tus publicaciones"
            case .logros: return "Medallas y hitos"
            case .guardados: return "Colección"
            case .estadisticas: return "Progreso"
            case .entrenos: return "Historial"
            case .amigos: return "Seguidores"
            case .retos: return "Objetivos"
            case .ajustes: return "Preferencias"
            }
        }
    }

    @State private var selected: Tab = .posts

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Carrusel horizontal
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Tab.allCases) { tab in
                        QuickCard(
                            title: tab.rawValue,
                            subtitle: tab.subtitle,
                            systemImage: tab.systemImage,
                            isSelected: selected == tab
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                selected = tab
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }

            // Contenido debajo según selección
            PerfilTabContentView(selected: selected)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - Card

    private struct QuickCard: View {
        let title: String
        let subtitle: String
        let systemImage: String
        let isSelected: Bool

        var body: some View {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Brand.red.opacity(0.18) : Brand.red.opacity(0.10))
                    Image(systemName: systemImage)
                        .foregroundStyle(isSelected ? Brand.red : Brand.red.opacity(0.9))
                        .font(.headline.weight(.semibold))
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(width: 220) // importante para “tarjeta” en carrusel
            .background(Brand.card)
            .clipShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .strokeBorder(isSelected ? Brand.red.opacity(0.35) : Brand.red.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Brand.red.opacity(isSelected ? 0.12 : 0.06), radius: 10, y: 6)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
    }
}

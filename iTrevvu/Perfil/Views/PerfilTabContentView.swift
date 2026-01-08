import SwiftUI

struct PerfilTabContentView: View {

    private enum Brand {
        static let red = Color.red
        static let card = Color(.secondarySystemBackground)
        static let corner: CGFloat = 18
    }

    let selected: PerfilQuickGridView.Tab

    var body: some View {
        VStack(spacing: 12) {

            switch selected {
            case .posts:
                SectionCard(title: "Mis posts", icon: "square.grid.2x2") {
                    EmptyState(
                        title: "Aún no hay posts",
                        subtitle: "Cuando publiques entrenos o contenido, aparecerán aquí.",
                        systemImage: "plus.square"
                    )
                }

            case .logros:
                SectionCard(title: "Logros", icon: "trophy") {
                    AchievementsPreview()
                }

            case .guardados:
                SectionCard(title: "Guardados", icon: "bookmark") {
                    EmptyState(
                        title: "Nada guardado todavía",
                        subtitle: "Guarda rutinas, posts o entrenos para verlos aquí.",
                        systemImage: "bookmark"
                    )
                }

            case .estadisticas:
                SectionCard(title: "Estadísticas", icon: "chart.line.uptrend.xyaxis") {
                    StatsPreview()
                }

            case .entrenos:
                SectionCard(title: "Entrenos", icon: "dumbbell") {
                    EmptyState(
                        title: "Sin historial todavía",
                        subtitle: "Completa entrenos para ver tu historial.",
                        systemImage: "dumbbell.fill"
                    )
                }

            case .amigos:
                SectionCard(title: "Amigos", icon: "person.2") {
                    EmptyState(
                        title: "Conecta con gente",
                        subtitle: "Sigue a deportistas para verlos aquí.",
                        systemImage: "person.badge.plus"
                    )
                }

            case .retos:
                SectionCard(title: "Retos", icon: "flag.checkered") {
                    ChallengesPreview()
                }

            case .ajustes:
                SectionCard(title: "Acceso rápido", icon: "gearshape") {
                    HStack(spacing: 12) {
                        NavigationLink {
                            Text("Ajustes (ya los tienes en la rueda arriba)")
                                .navigationTitle("Ajustes")
                        } label: {
                            QuickAction(title: "Abrir ajustes", systemImage: "gearshape.fill")
                        }

                        NavigationLink {
                            Text("Editar perfil (pendiente)")
                                .navigationTitle("Editar perfil")
                        } label: {
                            QuickAction(title: "Editar perfil", systemImage: "pencil")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Reusable UI

    private struct SectionCard<Content: View>: View {
        let title: String
        let icon: String
        @ViewBuilder let content: Content

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Brand.red.opacity(0.12))
                        Image(systemName: icon)
                            .foregroundStyle(Brand.red)
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(width: 34, height: 34)

                    Text(title)
                        .font(.headline.bold())

                    Spacer()
                }

                content
            }
            .padding(14)
            .background(Brand.card)
            .clipShape(RoundedRectangle(cornerRadius: Brand.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Brand.corner, style: .continuous)
                    .strokeBorder(Brand.red.opacity(0.10), lineWidth: 1)
            )
        }
    }

    private struct EmptyState: View {
        let title: String
        let subtitle: String
        let systemImage: String

        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Brand.red)

                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }

    private struct QuickAction: View {
        let title: String
        let systemImage: String

        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(Brand.red)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Brand.red.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Previews placeholders

    private struct AchievementsPreview: View {
        var body: some View {
            VStack(spacing: 10) {
                Row(title: "7 días seguidos", subtitle: "Racha semanal", systemImage: "flame.fill")
                Row(title: "PR en press banca", subtitle: "Nuevo récord", systemImage: "medal.fill")
                Row(title: "10 entrenos este mes", subtitle: "Constancia", systemImage: "calendar.badge.checkmark")
            }
        }

        private struct Row: View {
            let title: String
            let subtitle: String
            let systemImage: String

            var body: some View {
                HStack(spacing: 12) {
                    Image(systemName: systemImage)
                        .foregroundStyle(Color.red)
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.subheadline.weight(.semibold))
                        Text(subtitle).font(.caption).foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(12)
                .background(Color.red.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private struct StatsPreview: View {
        var body: some View {
            VStack(spacing: 10) {
                Metric(title: "Volumen", value: "12.4K kg", systemImage: "scalemass.fill")
                Metric(title: "Sesiones", value: "18", systemImage: "figure.strengthtraining.traditional")
            }
        }

        private struct Metric: View {
            let title: String
            let value: String
            let systemImage: String

            var body: some View {
                HStack {
                    Image(systemName: systemImage)
                        .foregroundStyle(Color.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.caption).foregroundStyle(.secondary)
                        Text(value).font(.headline.bold())
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.red.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private struct ChallengesPreview: View {
        var body: some View {
            VStack(spacing: 10) {
                ChallengeRow(title: "Reto 5K", subtitle: "Completa 5 km esta semana", progress: 0.45)
                ChallengeRow(title: "3 entrenos", subtitle: "Haz 3 sesiones", progress: 0.66)
            }
        }

        private struct ChallengeRow: View {
            let title: String
            let subtitle: String
            let progress: Double

            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title).font(.subheadline.weight(.semibold))
                            Text(subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.red)
                    }

                    ProgressView(value: progress)
                        .tint(.red)
                }
                .padding(12)
                .background(Color.red.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
}

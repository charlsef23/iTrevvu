import SwiftUI
import Supabase
import PostgREST

struct EjercicioEstadisticasHubView: View {

    private let accent = TrainingBrand.stats

    @State private var isLoading = false

    @State private var volumeLast30: Double = 0
    @State private var sessionsLast30: Int = 0
    @State private var prsLast30: Int = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {

                SportHeroCard(
                    title: "Estadísticas",
                    subtitle: "Volumen · sesiones · progreso",
                    icon: "chart.line.uptrend.xyaxis",
                    accent: accent
                )

                SectionHeader(title: "Resumen", actionTitle: nil, tint: accent) { }

                ExerciseStatsPreviewCardLive(
                    volume: volumeLast30,
                    sessions: sessionsLast30,
                    prs: prsLast30,
                    isLoading: isLoading
                )

                SectionHeader(title: "Métricas", actionTitle: nil, tint: nil) { }

                VStack(spacing: 12) {
                    NavigationLink { EjercicioStatsDetalleView(metricTitle: "Volumen") } label: {
                        MetricCard(title: "Volumen", value: formatKg(volumeLast30), subtitle: "Últimos 30 días", icon: "scalemass.fill", accent: accent)
                    }
                    .buttonStyle(.plain)

                    NavigationLink { EjercicioStatsDetalleView(metricTitle: "Sesiones") } label: {
                        MetricCard(title: "Sesiones", value: "\(sessionsLast30)", subtitle: "Últimos 30 días", icon: "calendar", accent: accent)
                    }
                    .buttonStyle(.plain)

                    NavigationLink { EjercicioStatsDetalleView(metricTitle: "PRs") } label: {
                        MetricCard(title: "PRs", value: "\(prsLast30)", subtitle: "Estimación (30 días)", icon: "medal.fill", accent: accent)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 24)
            }
            .padding(16)
        }
        .background(TrainingBrand.bg)
        .navigationTitle("Estadísticas")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .task { await loadStats() }
    }

    private func loadStats() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let service = TrainingSupabaseService(client: SupabaseManager.shared.client)
            let autorId = try service.currentUserId()

            // 1) sesiones recientes
            let sessions = try await service.fetchRecentSessions(autorId: autorId, limit: 250)

            let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let sessions30 = sessions.filter { $0.fecha >= fromDate }
            sessionsLast30 = sessions30.count

            // 2) volumen + PR estimation: necesitamos items + sets
            // (Como el service no tenía estas funciones, las hacemos aquí sin PostgREST import:
            // -> llamamos a SupabaseManager.shared.client desde el service file sería ideal.
            // Para mantenerlo simple, añadimos dos helpers al service.)
            let (vol, prs) = try await fetchVolumeAndPRs(sessionIds: sessions30.map { $0.id })
            volumeLast30 = vol
            prsLast30 = prs

        } catch {
            volumeLast30 = 0
            sessionsLast30 = 0
            prsLast30 = 0
        }
    }

    private func fetchVolumeAndPRs(sessionIds: [UUID]) async throws -> (Double, Int) {
        guard !sessionIds.isEmpty else { return (0, 0) }

        // ✅ aquí sí usamos el client, pero SIN depender de imports en este archivo:
        // el tipo DBSessionItem/DBSessionSet ya está en TrainingDTO.swift
        let client = SupabaseManager.shared.client

        let itemRows: [DBSessionItem] = try await client
            .from("sesion_items")
            .select()
            .in("sesion_id", values: sessionIds.map { $0.uuidString })
            .execute()
            .value

        guard !itemRows.isEmpty else { return (0, 0) }

        let setRows: [DBSessionSet] = try await client
            .from("sesion_sets")
            .select()
            .in("sesion_item_id", values: itemRows.map { $0.id.uuidString })
            .execute()
            .value

        var volume: Double = 0

        // PR estimation
        let itemToKey: [UUID: String] = Dictionary(uniqueKeysWithValues: itemRows.map { item in
            let key = item.ejercicio_id?.uuidString
                ?? item.ejercicio_usuario_id?.uuidString
                ?? item.nombre_snapshot
                ?? item.id.uuidString
            return (item.id, key)
        })

        var maxByExercise: [String: Double] = [:]

        for s in setRows {
            let reps = Double(s.reps ?? 0)
            let kg = s.peso_kg ?? 0
            volume += reps * kg

            if let key = itemToKey[s.sesion_item_id] {
                maxByExercise[key] = Swift.max(maxByExercise[key] ?? 0, kg)
            }
        }

        let prs = maxByExercise.values.filter { $0 > 0 }.count
        return (volume, prs)
    }

    private func formatKg(_ v: Double) -> String {
        if v >= 1000 { return String(format: "%.1fK kg", v / 1000.0) }
        return String(format: "%.0f kg", v)
    }
}

// MARK: - Components

private struct ExerciseStatsPreviewCardLive: View {
    let volume: Double
    let sessions: Int
    let prs: Int
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Resumen")
                        .font(.headline.bold())
                    Text("Últimos 30 días")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isLoading { ProgressView().scaleEffect(0.9) }
            }

            HStack(spacing: 10) {
                StatMini(title: "Volumen", value: formatted(volume), icon: "scalemass.fill")
                StatMini(title: "Sesiones", value: "\(sessions)", icon: "figure.strengthtraining.traditional")
                StatMini(title: "PRs", value: "\(prs)", icon: "medal.fill")
            }
        }
        .padding(14)
        .background(TrainingBrand.card)
        .clipShape(RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TrainingBrand.corner, style: .continuous)
                .strokeBorder(TrainingBrand.separator, lineWidth: 1)
        )
    }

    private func formatted(_ v: Double) -> String {
        if v >= 1000 { return String(format: "%.1fK kg", v / 1000.0) }
        return String(format: "%.0f kg", v)
    }
}

private struct StatMini: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(TrainingBrand.stats)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(TrainingBrand.stats.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(TrainingBrand.softFill(accent))
                Image(systemName: icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
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

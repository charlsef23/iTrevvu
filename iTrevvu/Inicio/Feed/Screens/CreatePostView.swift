import SwiftUI

struct CreatePostView: View {

    enum Mode {
        case text
        case media
        case workout
    }

    let mode: Mode
    let onPublish: (FeedPost) -> Void
    let onCancel: () -> Void

    @State private var text: String = ""
    @State private var selectedSport: SportType = .gym

    var body: some View {
        VStack(spacing: 16) {

            // Editor
            TextEditor(text: $text)
                .frame(minHeight: 140)
                .padding(12)
                .background(FeedBrand.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(FeedBrand.red.opacity(0.10), lineWidth: 1)
                )

            // Opciones según modo
            Group {
                switch mode {
                case .text:
                    HintCard(text: "Post solo texto, tipo Twitter.")

                case .media:
                    HintCard(text: "Aquí integrarás selector de fotos/vídeos. De momento placeholder.")
                    MediaPlaceholder()

                case .workout:
                    HintCard(text: "Aquí recibes el entrenamiento completado y se sube como post.")
                    SportPicker(selectedSport: $selectedSport)
                    WorkoutPreview(sport: selectedSport)
                }
            }

            Spacer()

            Button {
                onPublish(buildPost())
            } label: {
                Text("Publicar")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(FeedBrand.red)
        }
        .padding(16)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancelar") { onCancel() }
            }
        }
    }

    private var title: String {
        switch mode {
        case .text: return "Nuevo post"
        case .media: return "Nuevo media post"
        case .workout: return "Publicar entreno"
        }
    }

    private func buildPost() -> FeedPost {
        let author = FeedMockData.me
        switch mode {
        case .text:
            return FeedPost(
                id: UUID(),
                author: author,
                createdAt: .now,
                content: .text(text.trimmingCharacters(in: .whitespacesAndNewlines)),
                likes: 0, comments: 0, isLiked: false
            )

        case .media:
            let items: [MediaAttachment] = [
                .init(type: .image(url: nil), aspectRatio: 4.0/5.0)
            ]
            return FeedPost(
                id: UUID(),
                author: author,
                createdAt: .now,
                content: .media(text: text.trimmingCharacters(in: .whitespacesAndNewlines), items: items),
                likes: 0, comments: 0, isLiked: false
            )

        case .workout:
            let workout = WorkoutSummary(
                sport: selectedSport,
                title: "\(selectedSport.rawValue) · Sesión",
                durationMinutes: 42,
                calories: 380,
                mainMetric: selectedSport == .gym ? "Volumen 10.8K kg" : "Distancia 5.0 km",
                secondaryMetric: selectedSport == .gym ? "PRs 1" : "Ritmo 5:25/km"
            )
            return FeedPost(
                id: UUID(),
                author: author,
                createdAt: .now,
                content: .workout(text: text.trimmingCharacters(in: .whitespacesAndNewlines), workout: workout),
                likes: 0, comments: 0, isLiked: false
            )
        }
    }
}

// MARK: - Small UI

private struct HintCard: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FeedBrand.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct MediaPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.gray.opacity(0.18))
            .frame(height: 220)
            .overlay {
                Label("Selector de imágenes/vídeos (pendiente)", systemImage: "photo.on.rectangle")
                    .foregroundStyle(.secondary)
                    .font(.subheadline.weight(.semibold))
            }
    }
}

private struct SportPicker: View {
    @Binding var selectedSport: SportType
    var body: some View {
        Picker("Deporte", selection: $selectedSport) {
            ForEach(SportType.allCases) { sport in
                Text(sport.rawValue).tag(sport)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct WorkoutPreview: View {
    let sport: SportType
    var body: some View {
        WorkoutPostView(
            text: "Preview del entreno",
            workout: .init(
                sport: sport,
                title: "\(sport.rawValue) · Sesión",
                durationMinutes: 42,
                calories: 380,
                mainMetric: sport == .gym ? "Volumen 10.8K kg" : "Distancia 5.0 km",
                secondaryMetric: sport == .gym ? "PRs 1" : "Ritmo 5:25/km"
            )
        )
    }
}

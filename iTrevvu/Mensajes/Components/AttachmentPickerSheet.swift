import SwiftUI

struct AttachmentPickerSheet: View {

    enum Picked {
        case attachment(DMAttachment)
    }

    let onPick: (DMAttachment) -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Media") {
                    Row(title: "Foto", icon: "photo") {
                        onPick(.photo(localIdentifier: nil))
                    }
                    Row(title: "Vídeo", icon: "play.circle") {
                        onPick(.video(localIdentifier: nil))
                    }
                }

                Section("Entrenamiento") {
                    Row(title: "Rutina", icon: "list.bullet.rectangle") {
                        onPick(.routine(id: UUID(), title: "Upper · Fuerza", subtitle: "6 ejercicios · 45 min"))
                    }
                    Row(title: "Entrenamiento", icon: "dumbbell.fill") {
                        onPick(.workout(id: UUID(), title: "Gimnasio · Sesión", subtitle: "42 min · 380 kcal", sport: "Gimnasio"))
                    }
                    Row(title: "Estadísticas ejercicio", icon: "chart.line.uptrend.xyaxis") {
                        onPick(.link(urlString: "itrevvu://stats/pressbanca", title: "Stats · Press banca"))
                    }
                }

                Section("Nutrición") {
                    Row(title: "Dieta / Plan", icon: "leaf.fill") {
                        onPick(.diet(id: UUID(), title: "Plan definición", subtitle: "2300 kcal · alta proteína"))
                    }
                    Row(title: "Comida", icon: "fork.knife") {
                        onPick(.meal(id: UUID(), title: "Comida · Bowl", subtitle: "650 kcal · P45 C70 G18"))
                    }
                }

                Section("Social") {
                    Row(title: "Publicación del feed", icon: "square.grid.2x2") {
                        onPick(.feedPost(id: UUID(), author: "marcos_gym", preview: "Upper day. Buenas sensaciones 💪"))
                    }
                }
            }
            .navigationTitle("Enviar…")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { onClose() }
                }
            }
        }
        .tint(DMBrand.red)
    }

    private struct Row: View {
        let title: String
        let icon: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundStyle(DMBrand.red)
                        .frame(width: 22)
                    Text(title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .font(.footnote.weight(.semibold))
                }
            }
        }
    }
}

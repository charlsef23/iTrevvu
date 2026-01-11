import SwiftUI

struct SideMenuContainer<Content: View>: View {
    @Binding var isOpen: Bool
    let menuWidth: CGFloat
    let menu: () -> AnyView
    let content: () -> Content

    @State private var dragX: CGFloat = 0

    var body: some View {
        ZStack(alignment: .leading) {

            content()
                .disabled(isOpen)
                .overlay {
                    if isOpen {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()
                            .onTapGesture { close() }
                    }
                }

            // Panel
            menu()
                .frame(width: menuWidth)
                .offset(x: panelOffset)
                .shadow(color: .black.opacity(0.12), radius: 16, x: 6, y: 0)
        }
        .gesture(dragGesture)
        .animation(.spring(response: 0.32, dampingFraction: 0.92), value: isOpen)
    }

    private var panelOffset: CGFloat {
        // cuando está cerrado: -menuWidth
        // cuando está abierto: 0
        let base = isOpen ? 0 : -menuWidth
        return base + dragX
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .local)
            .onChanged { value in
                let x = value.translation.width

                // Si menú cerrado: solo permitir arrastrar a la derecha
                if !isOpen {
                    dragX = max(0, min(x, menuWidth))
                } else {
                    // Si abierto: permitir arrastrar hacia la izquierda para cerrar
                    dragX = min(0, max(x, -menuWidth))
                }
            }
            .onEnded { value in
                let x = value.translation.width

                if !isOpen {
                    // abrir si arrastra suficiente a la derecha
                    if x > menuWidth * 0.35 {
                        open()
                    } else {
                        close()
                    }
                } else {
                    // cerrar si arrastra suficiente a la izquierda
                    if x < -menuWidth * 0.25 {
                        close()
                    } else {
                        open()
                    }
                }

                dragX = 0
            }
    }

    private func open() { isOpen = true }
    private func close() { isOpen = false }
}

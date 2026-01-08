import SwiftUI

struct AjustesView: View {
    private enum Brand {
        static let red = Color.red
    }

    let onSignOutTapped: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {

                // Cabecera mini
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Brand.red.opacity(0.12))
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Brand.red)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ajustes")
                            .font(.headline.bold())
                        Text("Configura tu cuenta y la app")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 4)

                SettingsSectionCard(title: "Cuenta") {
                    NavigationLink {
                        Text("Privacidad (pendiente)")
                            .navigationTitle("Privacidad")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        SettingsRow(title: "Privacidad", systemImage: "lock", tint: Brand.red)
                    }

                    NavigationLink {
                        Text("Notificaciones (pendiente)")
                            .navigationTitle("Notificaciones")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        SettingsRow(title: "Notificaciones", systemImage: "bell", tint: Brand.red)
                    }

                    NavigationLink {
                        Text("Seguridad (pendiente)")
                            .navigationTitle("Seguridad")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        SettingsRow(title: "Seguridad", systemImage: "shield", tint: Brand.red)
                    }
                }

                SettingsSectionCard(title: "Soporte") {
                    NavigationLink {
                        Text("Centro de ayuda (pendiente)")
                            .navigationTitle("Ayuda")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        SettingsRow(title: "Centro de ayuda", systemImage: "questionmark.circle", tint: Brand.red)
                    }

                    NavigationLink {
                        Text("Sobre iTrevvu (pendiente)")
                            .navigationTitle("Sobre")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        SettingsRow(title: "Sobre iTrevvu", systemImage: "info.circle", tint: Brand.red)
                    }
                }

                Button {
                    onSignOutTapped()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar sesión")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .foregroundStyle(.red)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.red.opacity(0.18), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Brand.red)
    }
}

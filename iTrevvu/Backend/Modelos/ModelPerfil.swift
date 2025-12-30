import Foundation

struct Perfil: Codable, Identifiable {
    let id: UUID
    let username: String
    let nombre: String?
    let presentacion: String?
    let enlaces: [String: String]?
    let avatar_url: String?
}

struct PerfilInsert: Codable {
    let id: UUID
    let username: String
    let nombre: String?
    let presentacion: String?
    let enlaces: [String: String]?
    let avatar_url: String?
}

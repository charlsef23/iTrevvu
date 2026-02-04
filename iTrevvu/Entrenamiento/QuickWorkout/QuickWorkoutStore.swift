import Foundation
import Combine
import Supabase

@MainActor
final class QuickWorkoutStore: ObservableObject {

    @Published var types: [QuickWorkoutType] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func loadTypes() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let res = try await client
                .from("entrenamientos_rapidos")
                .select()
                .order("orden", ascending: true)
                .execute()

            let decoded = try JSONDecoder.supabase.decode([QuickWorkoutType].self, from: res.data)
            self.types = decoded
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func startSession(type: QuickWorkoutType, autorId: UUID) async -> QuickWorkoutSession? {
        do {
            let payload: [String: AnyEncodable] = [
                "autor_id": AnyEncodable(autorId),
                "entrenamiento_rapido_id": AnyEncodable(type.id)
            ]

            let res = try await client
                .from("sesiones_entrenamiento_rapido")
                .insert(payload, returning: .representation)
                .select()
                .single()
                .execute()

            return try JSONDecoder.supabase.decode(QuickWorkoutSession.self, from: res.data)
        } catch {
            self.errorMessage = error.localizedDescription
            return nil
        }
    }

    func finishSession(sessionId: UUID, seconds: Int, calories: Int? = nil, distanceM: Float? = nil) async {
        do {
            var payload: [String: AnyEncodable] = [
                "ended_at": AnyEncodable(Date()),
                "duracion_segundos": AnyEncodable(seconds)
            ]
            if let calories { payload["calorias"] = AnyEncodable(calories) }
            if let distanceM { payload["distancia_m"] = AnyEncodable(distanceM) }

            _ = try await client
                .from("sesiones_entrenamiento_rapido")
                .update(payload)
                .eq("id", value: sessionId.uuidString)
                .execute()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - JSON helpers

extension JSONDecoder {
    static var supabase: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}

// MARK: - AnyEncodable helper (para payloads)

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) { _encode = value.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
            let url = URL(string: urlString)
        else {
            fatalError("❌ Falta SUPABASE_URL o SUPABASE_ANON_KEY en Info.plist")
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }
    
    var currentUserId: UUID? {
           client.auth.currentSession?.user.id
       }
}

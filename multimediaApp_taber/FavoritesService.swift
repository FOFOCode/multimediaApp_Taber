import Foundation
import Combine

class FavoritesService: ObservableObject {
    static let shared = FavoritesService()
    
    @Published var favorites: [FavoriteVerse] = []
    
    private let favoritesKey = "bible_favorites"
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Load Favorites
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let decoded = try? JSONDecoder().decode([FavoriteVerse].self, from: data) else {
            favorites = []
            return
        }
        favorites = decoded.sorted { $0.timestamp > $1.timestamp }
    }
    
    // MARK: - Save Favorites
    
    private func saveFavorites() {
        guard let encoded = try? JSONEncoder().encode(favorites) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: favoritesKey)
    }
    
    // MARK: - Add Favorite
    
    func addFavorite(id: String, reference: String, text: String, bookName: String) {
        let favorite = FavoriteVerse(
            id: id,
            reference: reference,
            text: text,
            bookName: bookName,
            timestamp: Date()
        )
        
        // Evitar duplicados
        if !favorites.contains(where: { $0.id == id }) {
            favorites.insert(favorite, at: 0)
            saveFavorites()
        }
    }
    
    // MARK: - Remove Favorite
    
    func removeFavorite(id: String) {
        favorites.removeAll { $0.id == id }
        saveFavorites()
    }
    
    // MARK: - Toggle Favorite
    
    func toggleFavorite(id: String, reference: String, text: String, bookName: String) {
        if isFavorite(id: id) {
            removeFavorite(id: id)
        } else {
            addFavorite(id: id, reference: reference, text: text, bookName: bookName)
        }
    }
    
    // MARK: - Check if Favorite
    
    func isFavorite(id: String) -> Bool {
        favorites.contains { $0.id == id }
    }
    
    // MARK: - Clear All
    
    func clearAll() {
        favorites.removeAll()
        saveFavorites()
    }
}

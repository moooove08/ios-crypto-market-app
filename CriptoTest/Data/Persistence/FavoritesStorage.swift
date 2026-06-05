import Foundation

protocol FavoritesStorageProtocol: Sendable {
    func isFavorite(id: String) -> Bool
    func toggleFavorite(id: String)
    func favoriteIDs() -> Set<String>
}

final class FavoritesStorage: FavoritesStorageProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let key = "favorite_crypto_ids"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func isFavorite(id: String) -> Bool {
        favoriteIDs().contains(id)
    }

    func toggleFavorite(id: String) {
        var favorites = favoriteIDs()
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        userDefaults.set(Array(favorites), forKey: key)
    }

    func favoriteIDs() -> Set<String> {
        Set(userDefaults.stringArray(forKey: key) ?? [])
    }
}

import Foundation

final class CryptoRepository: CryptoRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol
    private let favoritesStorage: FavoritesStorageProtocol

    init(
        apiClient: APIClientProtocol = APIClient(),
        favoritesStorage: FavoritesStorageProtocol = FavoritesStorage()
    ) {
        self.apiClient = apiClient
        self.favoritesStorage = favoritesStorage
    }

    func fetchMarkets() async throws -> [CryptoCurrency] {
        let dtos = try await apiClient.fetchMarkets()
        return dtos.map { $0.toDomain() }
    }

    func fetchCoinDetails(id: String) async throws -> CryptoCurrency {
        let dto = try await apiClient.fetchCoinDetails(id: id)
        return dto.toDomain()
    }

    func isFavorite(id: String) -> Bool {
        favoritesStorage.isFavorite(id: id)
    }

    func toggleFavorite(id: String) {
        favoritesStorage.toggleFavorite(id: id)
    }
}

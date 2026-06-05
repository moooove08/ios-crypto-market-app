import Foundation

protocol CryptoRepositoryProtocol: Sendable {
    func fetchMarkets() async throws -> [CryptoCurrency]
    func fetchCoinDetails(id: String) async throws -> CryptoCurrency
    func isFavorite(id: String) -> Bool
    func toggleFavorite(id: String)
}

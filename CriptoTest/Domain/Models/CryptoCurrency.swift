import Foundation

struct CryptoCurrency: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let imageURL: URL?
    let currentPrice: Double
    let priceChangePercentage24h: Double
    let marketCap: Double?
    let high24h: Double?
    let low24h: Double?
    let description: String?

    var isPriceUp: Bool {
        priceChangePercentage24h >= 0
    }
}

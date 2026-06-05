import Foundation

struct CryptoMarketDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double?
    let high24h: Double?
    let low24h: Double?
    let priceChangePercentage24h: Double?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }

    func toDomain(description: String? = nil) -> CryptoCurrency {
        CryptoCurrency(
            id: id,
            name: name,
            symbol: symbol.uppercased(),
            imageURL: URL(string: image),
            currentPrice: currentPrice,
            priceChangePercentage24h: priceChangePercentage24h ?? 0,
            marketCap: marketCap,
            high24h: high24h,
            low24h: low24h,
            description: description
        )
    }
}

struct CoinDetailDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: ImageDTO
    let marketData: MarketDataDTO
    let description: DescriptionDTO?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image, description
        case marketData = "market_data"
    }

    struct ImageDTO: Decodable {
        let large: String
    }

    struct MarketDataDTO: Decodable {
        let currentPrice: PriceDTO
        let marketCap: PriceDTO?
        let high24h: PriceDTO?
        let low24h: PriceDTO?
        let priceChangePercentage24h: Double?

        enum CodingKeys: String, CodingKey {
            case currentPrice = "current_price"
            case marketCap = "market_cap"
            case high24h = "high_24h"
            case low24h = "low_24h"
            case priceChangePercentage24h = "price_change_percentage_24h"
        }
    }

    struct PriceDTO: Decodable {
        let usd: Double?
    }

    struct DescriptionDTO: Decodable {
        let en: String?
    }

    func toDomain() -> CryptoCurrency {
        let cleanDescription = description?.en?
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return CryptoCurrency(
            id: id,
            name: name,
            symbol: symbol.uppercased(),
            imageURL: URL(string: image.large),
            currentPrice: marketData.currentPrice.usd ?? 0,
            priceChangePercentage24h: marketData.priceChangePercentage24h ?? 0,
            marketCap: marketData.marketCap?.usd,
            high24h: marketData.high24h?.usd,
            low24h: marketData.low24h?.usd,
            description: cleanDescription?.isEmpty == false ? cleanDescription : nil
        )
    }
}

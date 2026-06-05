import Foundation

enum APIEndpoint {
    case markets
    case coinDetails(id: String)

    private static let baseURL = "https://api.coingecko.com/api/v3"

    var url: URL? {
        switch self {
        case .markets:
            var components = URLComponents(string: "\(Self.baseURL)/coins/markets")
            components?.queryItems = [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "per_page", value: "20"),
                URLQueryItem(name: "page", value: "1")
            ]
            return components?.url

        case .coinDetails(let id):
            var components = URLComponents(string: "\(Self.baseURL)/coins/\(id)")
            components?.queryItems = [
                URLQueryItem(name: "localization", value: "false"),
                URLQueryItem(name: "tickers", value: "false"),
                URLQueryItem(name: "market_data", value: "true"),
                URLQueryItem(name: "community_data", value: "false"),
                URLQueryItem(name: "developer_data", value: "false"),
                URLQueryItem(name: "sparkline", value: "false")
            ]
            return components?.url
        }
    }
}

import Foundation

protocol APIClientProtocol: Sendable {
    func fetchMarkets() async throws -> [CryptoMarketDTO]
    func fetchCoinDetails(id: String) async throws -> CoinDetailDTO
}

final class APIClient: APIClientProtocol, @unchecked Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchMarkets() async throws -> [CryptoMarketDTO] {
        try await request(endpoint: .markets)
    }

    func fetchCoinDetails(id: String) async throws -> CoinDetailDTO {
        try await request(endpoint: .coinDetails(id: id))
    }

    private func request<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

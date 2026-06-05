import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Невірна URL-адреса"
        case .invalidResponse:
            return "Невірна відповідь сервера"
        case .httpError(let statusCode):
            return "Помилка сервера (код \(statusCode))"
        case .decodingError:
            return "Помилка обробки даних"
        case .networkError:
            return "Немає з'єднання з інтернетом"
        }
    }
}

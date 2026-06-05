import Foundation

@MainActor
final class DetailsViewModel {
    enum ViewState: Equatable {
        case loading
        case loaded
        case error(String)
    }

    private(set) var state: ViewState = .loading
    private(set) var coin: CryptoCurrency
    private(set) var isFavorite: Bool

    var onStateChanged: (() -> Void)?
    var onFavoriteChanged: (() -> Void)?

    private let repository: CryptoRepositoryProtocol

    init(coin: CryptoCurrency, repository: CryptoRepositoryProtocol) {
        self.coin = coin
        self.repository = repository
        self.isFavorite = repository.isFavorite(id: coin.id)
    }

    func loadDetails() async {
        state = .loading
        notifyStateChanged()

        do {
            coin = try await repository.fetchCoinDetails(id: coin.id)
            state = .loaded
        } catch let error as APIError {
            state = .error(error.errorDescription ?? "Невідома помилка")
        } catch {
            state = .error("Щось пішло не так")
        }

        notifyStateChanged()
    }

    func toggleFavorite() {
        repository.toggleFavorite(id: coin.id)
        isFavorite = repository.isFavorite(id: coin.id)
        onFavoriteChanged?()
    }

    private func notifyStateChanged() {
        onStateChanged?()
    }
}

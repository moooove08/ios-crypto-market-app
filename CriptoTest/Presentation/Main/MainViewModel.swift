import Foundation

@MainActor
final class MainViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    private(set) var state: ViewState = .idle
    private(set) var filteredCoins: [CryptoCurrency] = []

    var onStateChanged: (() -> Void)?

    private let repository: CryptoRepositoryProtocol
    private var allCoins: [CryptoCurrency] = []
    private var searchQuery = ""

    init(repository: CryptoRepositoryProtocol) {
        self.repository = repository
    }

    func loadCoins() async {
        if allCoins.isEmpty {
            state = .loading
            notifyStateChanged()
        }

        do {
            allCoins = try await repository.fetchMarkets()
            applyFilter()
            state = filteredCoins.isEmpty ? .empty : .loaded
        } catch let error as APIError {
            state = .error(error.errorDescription ?? "Невідома помилка")
        } catch {
            state = .error("Щось пішло не так")
        }

        notifyStateChanged()
    }

    func refresh() async {
        await loadCoins()
    }

    func search(query: String) {
        searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        applyFilter()
        state = filteredCoins.isEmpty && !allCoins.isEmpty ? .empty : .loaded
        notifyStateChanged()
    }

    func coin(at index: Int) -> CryptoCurrency? {
        guard filteredCoins.indices.contains(index) else { return nil }
        return filteredCoins[index]
    }

    private func applyFilter() {
        guard !searchQuery.isEmpty else {
            filteredCoins = allCoins
            return
        }

        let query = searchQuery.lowercased()
        filteredCoins = allCoins.filter {
            $0.name.lowercased().contains(query) ||
            $0.symbol.lowercased().contains(query)
        }
    }

    private func notifyStateChanged() {
        onStateChanged?()
    }
}

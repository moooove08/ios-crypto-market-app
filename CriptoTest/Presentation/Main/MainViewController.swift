import UIKit

final class MainViewController: UIViewController {
    private let viewModel: MainViewModel
    private let repository: CryptoRepositoryProtocol

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Пошук за назвою або тікером"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CryptoListCell.self, forCellReuseIdentifier: CryptoListCell.reuseIdentifier)
        tableView.rowHeight = 72
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 16)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return control
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Нічого не знайдено"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    init(viewModel: MainViewModel, repository: CryptoRepositoryProtocol) {
        self.viewModel = viewModel
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        Task { await viewModel.loadCoins() }
    }

    private func setupUI() {
        title = "Криптовалюти"
        view.backgroundColor = .systemBackground

        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateLabel)

        tableView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] in
            self?.renderState()
        }
    }

    private func renderState() {
        switch viewModel.state {
        case .idle:
            break

        case .loading:
            if viewModel.filteredCoins.isEmpty {
                activityIndicator.startAnimating()
                tableView.isHidden = true
            }
            emptyStateLabel.isHidden = true

        case .loaded:
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.isHidden = false
            emptyStateLabel.isHidden = true
            tableView.reloadData()

        case .empty:
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.isHidden = true
            emptyStateLabel.isHidden = false

        case .error(let message):
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.isHidden = viewModel.filteredCoins.isEmpty
            emptyStateLabel.isHidden = true
            showError(message)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Помилка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Повторити", style: .default) { [weak self] _ in
            Task { await self?.viewModel.loadCoins() }
        })
        present(alert, animated: true)
    }

    @objc private func handleRefresh() {
        Task { await viewModel.refresh() }
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredCoins.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CryptoListCell.reuseIdentifier,
                for: indexPath
            ) as? CryptoListCell,
            let coin = viewModel.coin(at: indexPath.row)
        else {
            return UITableViewCell()
        }

        cell.configure(with: coin)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()

        guard let coin = viewModel.coin(at: indexPath.row) else { return }
        openDetails(for: coin)
    }

    private func openDetails(for coin: CryptoCurrency) {
        let detailsViewModel = DetailsViewModel(coin: coin, repository: repository)
        let detailsVC = DetailsViewController(viewModel: detailsViewModel)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

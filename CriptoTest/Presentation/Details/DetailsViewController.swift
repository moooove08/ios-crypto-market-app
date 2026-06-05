import UIKit

final class DetailsViewController: UIViewController {
    private let viewModel: DetailsViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        return stack
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 32
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var favoriteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.title = "Додати в обране"

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var imageLoadTask: Task<Void, Never>?

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        renderCoin()
        Task { await viewModel.loadDetails() }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let titleStack = UIStackView(arrangedSubviews: [nameLabel, symbolLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 4

        headerStack.addArrangedSubview(iconImageView)
        headerStack.addArrangedSubview(titleStack)

        let priceStack = UIStackView(arrangedSubviews: [priceLabel, changeLabel])
        priceStack.axis = .vertical
        priceStack.spacing = 4
        priceStack.alignment = .leading

        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(priceStack)
        contentStack.addArrangedSubview(makeSectionTitle("Статистика"))
        contentStack.addArrangedSubview(statsStack)
        contentStack.addArrangedSubview(makeSectionTitle("Опис"))
        contentStack.addArrangedSubview(descriptionLabel)
        contentStack.addArrangedSubview(favoriteButton)

        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 64),
            iconImageView.heightAnchor.constraint(equalToConstant: 64),

            favoriteButton.heightAnchor.constraint(equalToConstant: 50),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] in
            self?.renderState()
        }

        viewModel.onFavoriteChanged = { [weak self] in
            self?.updateFavoriteButton()
        }
    }

    private func renderState() {
        switch viewModel.state {
        case .loading:
            activityIndicator.startAnimating()
            scrollView.alpha = 0.5

        case .loaded:
            activityIndicator.stopAnimating()
            scrollView.alpha = 1
            renderCoin()

        case .error(let message):
            activityIndicator.stopAnimating()
            scrollView.alpha = 1
            showError(message)
        }
    }

    private func renderCoin() {
        let coin = viewModel.coin

        title = coin.name
        nameLabel.text = coin.name
        symbolLabel.text = coin.symbol
        priceLabel.text = Formatters.formatPrice(coin.currentPrice)
        changeLabel.text = Formatters.formatPercentage(coin.priceChangePercentage24h)
        changeLabel.textColor = coin.isPriceUp ? .systemGreen : .systemRed

        updateStats(coin)
        descriptionLabel.text = coin.description ?? "Опис для цієї монети наразі недоступний."

        imageLoadTask?.cancel()
        imageLoadTask = Task { [weak self] in
            guard let self else { return }
            let image = await ImageLoader.shared.loadImage(from: coin.imageURL)
            guard !Task.isCancelled else { return }
            self.iconImageView.image = image
        }

        updateFavoriteButton()
    }

    private func updateStats(_ coin: CryptoCurrency) {
        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        statsStack.addArrangedSubview(makeStatRow(title: "Ринкова капіталізація", value: Formatters.formatMarketCap(coin.marketCap)))
        statsStack.addArrangedSubview(makeStatRow(title: "Макс. 24г", value: coin.high24h.map { Formatters.formatPrice($0) } ?? "—"))
        statsStack.addArrangedSubview(makeStatRow(title: "Мін. 24г", value: coin.low24h.map { Formatters.formatPrice($0) } ?? "—"))
    }

    private func updateFavoriteButton() {
        var config = favoriteButton.configuration ?? UIButton.Configuration.filled()
        if viewModel.isFavorite {
            config.title = "В обраному"
            config.baseBackgroundColor = .systemOrange
            config.image = UIImage(systemName: "star.fill")
        } else {
            config.title = "Додати в обране"
            config.baseBackgroundColor = .systemBlue
            config.image = UIImage(systemName: "star")
        }
        config.imagePadding = 8
        favoriteButton.configuration = config
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }

    private func makeStatRow(title: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .secondaryLabel

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Помилка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Повторити", style: .default) { [weak self] _ in
            Task { await self?.viewModel.loadDetails() }
        })
        present(alert, animated: true)
    }

    @objc private func toggleFavorite() {
        viewModel.toggleFavorite()
    }
}

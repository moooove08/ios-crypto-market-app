import UIKit

final class CryptoListCell: UITableViewCell {
    static let reuseIdentifier = "CryptoListCell"

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()

    private let changeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    private var imageLoadTask: Task<Void, Never>?
    private var currentImageURL: URL?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        if let url = currentImageURL {
            ImageLoader.shared.cancelLoad(for: url)
        }
        currentImageURL = nil
        iconImageView.image = nil
    }

    func configure(with coin: CryptoCurrency) {
        nameLabel.text = coin.name
        symbolLabel.text = coin.symbol
        priceLabel.text = Formatters.formatPrice(coin.currentPrice)
        changeLabel.text = Formatters.formatPercentage(coin.priceChangePercentage24h)
        changeLabel.textColor = coin.isPriceUp ? .systemGreen : .systemRed

        currentImageURL = coin.imageURL
        iconImageView.image = nil

        imageLoadTask = Task { [weak self] in
            guard let self, let url = coin.imageURL else { return }
            let image = await ImageLoader.shared.loadImage(from: url)
            guard !Task.isCancelled, self.currentImageURL == url else { return }
            self.iconImageView.image = image
        }
    }

    private func setupUI() {
        accessoryType = .disclosureIndicator
        selectionStyle = .default

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, symbolLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2
        nameStack.translatesAutoresizingMaskIntoConstraints = false

        let priceStack = UIStackView(arrangedSubviews: [priceLabel, changeLabel])
        priceStack.axis = .vertical
        priceStack.spacing = 2
        priceStack.alignment = .trailing
        priceStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconImageView)
        contentView.addSubview(nameStack)
        contentView.addSubview(priceStack)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            nameStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            nameStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameStack.trailingAnchor.constraint(lessThanOrEqualTo: priceStack.leadingAnchor, constant: -12),

            priceStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            priceStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
}

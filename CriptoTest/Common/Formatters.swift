import Foundation

enum Formatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    static let compactCurrency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static let percentage: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "+"
        return formatter
    }()

    static func formatPrice(_ value: Double) -> String {
        if value >= 1 {
            return currency.string(from: NSNumber(value: value)) ?? "$\(value)"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    static func formatMarketCap(_ value: Double?) -> String {
        guard let value else { return "—" }

        let billion = 1_000_000_000.0
        let million = 1_000_000.0

        if value >= billion {
            return String(format: "$%.2fB", value / billion)
        } else if value >= million {
            return String(format: "$%.2fM", value / million)
        }
        return compactCurrency.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }

    static func formatPercentage(_ value: Double) -> String {
        let formatted = percentage.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(formatted)%"
    }
}

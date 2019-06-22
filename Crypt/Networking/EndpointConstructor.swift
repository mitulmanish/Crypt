import Foundation
enum EndPointConstructor {
    case allCoins
    case historicalData(coin: Coin, date: Date, currency: String)
    case history(coin: Coin, fromDate: Date, toDate: Date, currency: String)
    case currencies
    
    var formattedEndpoint: String {
        switch self {
        case .allCoins:
            return "coin/list"
        case .historicalData(let coin, let date, let currency):
            let formattedDate = getFormattedDate(date: date)
            return "coin/view/\(coin.id)/\(formattedDate)/\(currency)"
        case .history(let coin, let fromDate, let toDate, let currency):
            let fromFormattedDate = getFormattedDate(date: fromDate)
            let toFormattedDate = getFormattedDate(date: toDate)
            return "coin/history/\(coin.id)/\(fromFormattedDate)/\(toFormattedDate)/price/\(currency)"
        case .currencies:
            return "base-currency/list"
        }
    }
    
    func getFormattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

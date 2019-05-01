import Foundation
enum EndPointConstructor {
    case allCoins
    case historicalData(coin: Coin, date: Date, currency: String)
    case history(coin: Coin, fromDate: Date, toDate: Date, currency: String)
    
    var formattedEndpoint: String {
        switch self {
        case .allCoins:
            return "list"
        case .historicalData(let coin, let date, let currency):
            let formattedDate = getFormattedDate(date: date)
            return "view/\(coin.id)/\(formattedDate)/\(currency)"
        case .history(let coin, let fromDate, let toDate, let currency):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fromFormattedDate = getFormattedDate(date: fromDate)
            let toFormattedDate = getFormattedDate(date: toDate)
            return "history/\(coin.id)/\(fromFormattedDate)/\(toFormattedDate)/price/\(currency)"
        }
    }
    
    func getFormattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
//https://www.cryptocurrencychart.com/api/coin/history/363/2017-01-01/2017-01-02/price/USD

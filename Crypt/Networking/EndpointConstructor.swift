import Foundation
enum EndPointConstructor {
    case allCoins
    case historicalData(coin: Coin, date: Date, currency: String)
    
    var formattedEndpoint: String {
        switch self {
        case .allCoins:
            return "/coin/list"
        case .historicalData(let coin, let date, let currency):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: date)
            return "/coin/view/\(coin.id)/\(formattedDate)/\(currency)"
        }
    }
}

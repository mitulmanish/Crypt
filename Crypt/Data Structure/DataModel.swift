import Foundation

struct CoinPrice {
    let old: Float
    let latest: Float
}

struct Coin: Codable, Equatable {
    let id: Int
    let name: String
    let code: String
}

struct CoinCollection: Codable {
    let coins: [Coin]
}

struct CryptoHistoricalData: Codable {
    
    let coin: Coin
    
    var finalPrice: Float? {
        Float(coin.price)
    }
}

extension CryptoHistoricalData {
    
    struct Coin: Codable {
        
        var requestedDate: Date? {
            date(fromString: date)
        }
        
        let id: Int
        let baseCurrency: String
        let date: String
        let price: String
        
        private func date(fromString string: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.calendar = Calendar.autoupdatingCurrent
            dateFormatter.timeZone = Calendar.autoupdatingCurrent.timeZone
            return dateFormatter.date(from: string)
        }
    }
}

struct CurrecyHolder: Decodable {
    let baseCurrencies: [String]
    
    var currencyList: [Currency] {
        return baseCurrencies.compactMap({ Currency(rawValue: $0)})
    }
}

enum Currency: String {
    case usd = "USD"
    case eur = "EUR"
    case aud = "AUD"
    case bgn = "BGN"
    case brl = "BRL"
    case cad = "CAD"
    case chf = "CHF"
    case cny = "CNY"
    case czk = "CZK"
    case dkk = "DKK"
    case gbp = "GBP"
    case hkd = "HKD"
    case hrk = "HRK"
    case huf = "HUF"
    case idr = "IDR"
    case ils = "ILS"
    case inr = "INR"
    case jpy = "JPY"
    case krw = "KRW"
    case mxn = "MXN"
    case myr = "MYR"
    case nok = "NOK"
    case nzd = "NZD"
    case php = "PHP"
    case pln = "PLN"
    case ron = "RON"
    case rub = "RUB"
    case sek = "SEK"
    case sgd = "SGD"
    case thb = "THB"
    case `try` = "TRY"
    case zar = "ZAR"
    
    var flag: String {
        switch self {
        case .usd:
            return "🇺🇸"
        case .eur:
            return "🇪🇺"
        case .aud:
            return "🇦🇺"
        case .bgn:
            return "🇧🇬"
        case .brl:
            return "🇧🇷"
        case .cad:
            return "🇨🇦"
        case .chf:
            return "🇨🇭"
        case .cny:
            return "🇨🇳"
        case .czk:
            return "🇨🇿"
        case .dkk:
            return "🇩🇰"
        case .gbp:
            return "🇬🇧"
        case .hkd:
            return "🇭🇰"
        case .hrk:
            return "🇭🇷"
        case .huf:
            return "🇭🇺"
        case .idr:
            return "🇮🇩"
        case .ils:
            return "🇮🇱"
        case .inr:
            return "🇮🇳"
        case .jpy:
            return "🇯🇵"
        case .krw:
            return "🇰🇷"
        case .mxn:
            return "🇲🇽"
        case .myr:
            return "🇲🇾"
        case .nok:
            return "🇳🇴"
        case .nzd:
            return "🇳🇿"
        case .php:
            return "🇵🇭"
        case .pln:
            return "🇵🇱"
        case .ron:
            return "🇷🇴"
        case .rub:
            return "🇷🇺"
        case .sek:
            return "🇸🇪"
        case .sgd:
            return "🇸🇬"
        case .thb:
            return "🇹🇭"
        case .try:
            return "🇹🇷"
        case .zar:
            return "🇿🇦"
        }
    }
    
    var currencyName: String {
        return rawValue
    }
}

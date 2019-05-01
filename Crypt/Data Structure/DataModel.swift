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
    let id: Int
    let baseCurrency: String
    
    private let date: String
    private let rawPrice: String
    let firstData: String
    let mostRecentData: String
    
    var price: Float? {
        return Float(rawPrice)
    }
    
    var requestedDate: Date? {
        return date(fromString: date)
    }
    
    enum HistoryKeys: String, CodingKey {
        case coin
    }
    
    enum CoinKeys: String, CodingKey {
        case id
        case baseCurrency
        case date
        case rawPrice = "price"
        case firstData
        case mostRecentData
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: HistoryKeys.self)
        let container = try values.nestedContainer(keyedBy: CoinKeys.self, forKey: .coin)
        self.id = try container.decode(Int.self, forKey: .id)
        self.baseCurrency = try container.decode(String.self, forKey: .baseCurrency)
        self.date = try container.decode(String.self, forKey: .date)
        self.firstData = try container.decode(String.self, forKey: .firstData)
        self.mostRecentData = try container.decode(String.self, forKey: .mostRecentData)
        self.rawPrice = try container.decode(String.self, forKey: .rawPrice)
    }
    
    func date(fromString string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar.autoupdatingCurrent
        dateFormatter.timeZone = Calendar.autoupdatingCurrent.timeZone
        return dateFormatter.date(from: string)
    }
}

struct CoinPriceData: Decodable {
    let price: Double
    let date: String
}

struct CoinHistoricalPrice: Decodable {
    let coin: Coin
    let data: [CoinPriceData]
}

import Foundation
import Combine
import NetworkingKit

enum HistoricalPriceError: Error {
    case cantFetchOldPrice
    case cantFetchLatestPrice
    
    var description: String {
        switch self {
        case .cantFetchOldPrice, .cantFetchLatestPrice:
            return "☹️ There seems to be a problem with the network. Try again later."
        }
    }
}

struct HistoricalDataNetworkOperationManager {
    
    func requestCoinHistoricalData(
        forDates dates: (old: Date, latest: Date),
        forCoin coin: Coin,
        forCurrency currency: String,
        completionHandler: @escaping ((CoinPrice?, Error?) -> ())
        ) {
        let oldPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.old, currency: currency)
        let latestPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.latest, currency: currency)
        
        guard let oldPriceRequest = RequestFactory.getRequest(endpointType: oldPriceEndpoint),
            let latestPriceRequest = RequestFactory.getRequest(endpointType: latestPriceEndpoint) else {
                return
        }
        
        let oldPriceOperation = NetworkOperation(urlRequest: oldPriceRequest)

        let oldPriceDecodingOperation = DecodingOperation<CryptoHistoricalData, NetworkOperation>()
        oldPriceDecodingOperation.addDependency(oldPriceOperation)

        let latestPriceOperation = NetworkOperation(urlRequest: latestPriceRequest)
        latestPriceOperation.addDependency(oldPriceDecodingOperation)

        let latestPriceDecodingOperation = DecodingOperation<CryptoHistoricalData, NetworkOperation>()
        latestPriceDecodingOperation.addDependency(latestPriceOperation)
        
        let opeartionQueue = OperationQueue()
        opeartionQueue.addOperations([oldPriceOperation, oldPriceDecodingOperation, latestPriceOperation, latestPriceDecodingOperation], waitUntilFinished: false)

        latestPriceDecodingOperation.completionBlock = {
            if let oldPrice = oldPriceDecodingOperation.decodedObject?.finalPrice, let latestPrice = latestPriceDecodingOperation.decodedObject?.finalPrice {
                let price = CoinPrice(old: oldPrice, latest: latestPrice)
                OperationQueue.main.addOperation {
                    completionHandler(price, nil)
                }
            } else {
                OperationQueue.main.addOperation {
                    completionHandler(nil, HistoricalPriceError.cantFetchLatestPrice)
                }
            }
        }
    }
}

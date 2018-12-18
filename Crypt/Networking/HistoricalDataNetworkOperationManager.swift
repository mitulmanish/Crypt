import Foundation

enum HistoricalPriceError: Error {
    case cantFetchOldPrice
    case cantFetchLatestPrice
}

struct HistoricalDataNetworkOperationManager {
    private(set) var oldPrice: Float?
    private(set) var currentPrice: Float?

    func requestCoinHistoricalData(
        forDates dates: (old: Date, latest: Date),
        forCoin coin: Coin,
        forCurrency currency: String,
        completionHandler: @escaping ((CoinPrice?, HistoricalPriceError?) -> ())
        ) {
        
        let oldPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.old, currency: currency)
        let latestPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.latest, currency: currency)
        
        guard let oldPriceRequest = RequestFactory.getRequest(endpointType: oldPriceEndpoint),
            let latestPriceRequest = RequestFactory.getRequest(endpointType: latestPriceEndpoint) else {
                return
        }
        
        let oldPriceOperation = NetworkOperation(session: URLSession(configuration: .default), urlRequest: oldPriceRequest)

        let oldPriceDecodingOperation = DecodingOperation<CryptoHistoricalData>()
        oldPriceDecodingOperation.addDependency(oldPriceOperation)

        let latestPriceOperation = NetworkOperation(session: URLSession(configuration: .default), urlRequest: latestPriceRequest)
        latestPriceOperation.addDependency(oldPriceDecodingOperation)

        let latestPriceDecodingOperation = DecodingOperation<CryptoHistoricalData>()
        latestPriceDecodingOperation.addDependency(latestPriceOperation)
        
        let opeartionQueue = OperationQueue()
        opeartionQueue.addOperations([oldPriceOperation, oldPriceDecodingOperation, latestPriceOperation, latestPriceDecodingOperation], waitUntilFinished: false)

        latestPriceDecodingOperation.completionBlock = {
            if let oldPrice = oldPriceDecodingOperation.decodedObject?.price, let latestPrice = latestPriceDecodingOperation.decodedObject?.price {
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

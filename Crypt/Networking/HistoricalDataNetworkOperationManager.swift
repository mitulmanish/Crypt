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
    
    private var cancellableTask: AnyCancellable?
    
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
    
    mutating func price(
    forDates dates: (old: Date, latest: Date),
    forCoin coin: Coin,
    forCurrency currency: String,
    completionHandler: @escaping ((CoinPrice?, Error?) -> ())
    ) {
        if cancellableTask != nil {
            cancellableTask?.cancel()
        }
        let oldPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.old, currency: currency)
        let latestPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.latest, currency: currency)
        
        guard let oldPriceRequest = RequestFactory.getRequest(endpointType: oldPriceEndpoint),
            let latestPriceRequest = RequestFactory.getRequest(endpointType: latestPriceEndpoint) else {
                return
        }
        
        let oldPricePublisher: AnyPublisher<CryptoHistoricalData, Error> = NetworkingPublisher.dataPublisher(urlRequest: oldPriceRequest)
        let latestPricePublisher: AnyPublisher<CryptoHistoricalData, Error> = NetworkingPublisher.dataPublisher(urlRequest: latestPriceRequest)
        
        cancellableTask = Publishers.Zip(
            oldPricePublisher,
            latestPricePublisher
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { result in
            switch result {
            case let .failure(error):
                completionHandler(nil, error)
            case .finished:
                break
            }
        }, receiveValue: { oldPriceHistoricalData, latestPriceHistoricalData in
            guard let oldPrice = oldPriceHistoricalData.price, let latestPrice = latestPriceHistoricalData.price else {
                completionHandler(nil, HistoricalPriceError.cantFetchLatestPrice)
                return
            }
            completionHandler(
                CoinPrice(old: oldPrice, latest: latestPrice),
                nil
            )
        })
    }
}

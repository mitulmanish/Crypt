import Combine
import Foundation
import NetworkingKit

struct HistoricalPriceComparisonProvider {
    
    let networkActivityPublisher = PassthroughSubject<Bool, Never>()
    
    private var cancellableTask: AnyCancellable?
    
    mutating func price(
        forDates dates: (old: Date, latest: Date),
        forCoin coin: Coin,
        forCurrency currency: String,
        completionHandler: @escaping ((CoinPrice?, Error?) -> Void)
    ) {
        if cancellableTask != nil {
            cancellableTask?.cancel()
        }
        
        networkActivityPublisher.send(true)
        
        let oldPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.old, currency: currency)
        let latestPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.latest, currency: currency)
        
        guard let oldPriceRequest = RequestFactory.getRequest(endpointType: oldPriceEndpoint),
            let latestPriceRequest = RequestFactory.getRequest(endpointType: latestPriceEndpoint) else {
                networkActivityPublisher.send(false)
                return
        }
        
        let oldPricePublisher: AnyPublisher<CryptoHistoricalData, Error> =
            NetworkingPublisher.dataPublisher(
            urlRequest: oldPriceRequest
        )
        let latestPricePublisher: AnyPublisher<CryptoHistoricalData, Error> =
            NetworkingPublisher.dataPublisher(
            urlRequest: latestPriceRequest
        )
        
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
            }, receiveValue: { [networkActivityPublisher] oldPriceHistoricalData, latestPriceHistoricalData in
                guard let oldPrice = oldPriceHistoricalData.finalPrice,
                    let latestPrice = latestPriceHistoricalData.finalPrice else {
                    networkActivityPublisher.send(false)
                    completionHandler(nil, HistoricalPriceError.cantFetchLatestPrice)
                    return
                }
                networkActivityPublisher.send(false)
                completionHandler(
                    CoinPrice(old: oldPrice, latest: latestPrice),
                    nil
                )
            })
    }
}

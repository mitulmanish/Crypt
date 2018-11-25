//
//  HistoricalDataNetworkOperationManager.swift
//  Crypt
//
//  Created by Mitul Manish on 21/10/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//

import Foundation



enum HistoricalPriceError: Error {
    case cantFetchOldPrice
    case cantFetchLatestPrice
}

class HistoricalDataNetworkOperationManager {
    private(set) var oldPrice: Float?
    private(set) var currentPrice: Float?
    
    var completionHandler: ((CoinPrice?, HistoricalPriceError?) -> ())?
    func requestCoinHistoricalData(
        forDates dates: (old: Date, latest: Date),
        forCoin coin: Coin,
        forCurrency currency: String
        ) {
        
        let oldPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.old, currency: currency)
        let latestPriceEndpoint = EndPointConstructor.historicalData(coin: coin, date: dates.latest, currency: currency)
        
        guard let oldPriceRequest = RequestFactory.getHistoricalDataRequest(endpointType: oldPriceEndpoint),
            let latestPriceRequest = RequestFactory.getHistoricalDataRequest(endpointType: latestPriceEndpoint) else {
                return
        }
        
        let oldPriceOperation = NetworkOperation(session: URLSession(configuration: .default), urlRequest: oldPriceRequest)
        let latestPriceOperation = NetworkOperation(session: URLSession(configuration: .default), urlRequest: latestPriceRequest)
        
        latestPriceOperation.addDependency(oldPriceOperation)
        
        let opeartionQueue = OperationQueue()
        opeartionQueue.addOperations([latestPriceOperation, oldPriceOperation], waitUntilFinished: false)
        
        oldPriceOperation.completionBlock = {
            if let oldPriceData = oldPriceOperation.serverData, let historicalData = try? JSONDecoder().decode(CryptoHistoricalData.self, from: oldPriceData) {
                self.oldPrice = historicalData.price
            } else {
                self.completionHandler?(nil, HistoricalPriceError.cantFetchOldPrice)
            }
        }
        
        latestPriceOperation.completionBlock = {
            if let latestPriceData = latestPriceOperation.serverData, let historicalData = try? JSONDecoder().decode(CryptoHistoricalData.self, from: latestPriceData) {
                self.currentPrice = historicalData.price
                let price = CoinPrice(old: self.oldPrice ?? 0.0, latest: self.currentPrice ?? 0)
                OperationQueue.main.addOperation {
                    self.completionHandler?(price, nil)
                }
            } else {
                self.completionHandler?(nil, HistoricalPriceError.cantFetchLatestPrice)
            }
        }
    }
}

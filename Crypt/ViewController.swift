//
//  ViewController.swift
//  Crypt
//
//  Created by Mitul Manish on 24/4/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coin = Coin(id: 363, name: "Bitcoin", code: "BTC")
        let historicalDataNetworkOperationManager = HistoricalDataNetworkOperationManager()
        historicalDataNetworkOperationManager.completionHandler = { (price, error) in
            print("\(price)")
        }
        historicalDataNetworkOperationManager.requestCoinHistoricalData(
            forDates: (old: Date().addingTimeInterval(-24 * 60 * 60 * 60),
                       latest: Date()),
            forCoin: coin, forCurrency: "usd"
        )
    }
}

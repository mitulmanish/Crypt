//
//  PriceRequestParams.swift
//  Crypt
//
//  Created by Mitul Manish on 18/3/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//
import Foundation

struct PriceRequestParams {
    let quantityBought: Float
    let currentDate: Date
    let historicalDate: Date
    let coin: Coin
}

extension PriceRequestParams: Equatable {
    static func ==(lhs: PriceRequestParams, rhs: PriceRequestParams) -> Bool {
        return lhs.historicalDate.compare(rhs.historicalDate) == .orderedSame
            && lhs.quantityBought == rhs.quantityBought
            && lhs.coin == rhs.coin
    }
}

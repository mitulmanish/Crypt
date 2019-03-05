//
//  ProfitCalculator.swift
//  Crypt
//
//  Created by Mitul Manish on 5/3/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

enum PortfolioType {
    case profit(amount: Float, currentValue: Float)
    case loss(amount: Float, currentValue: Float)
    case neutral
}

struct ProfitCalculator {
    let moneySpent: Float
    let currectPrice: Float
    let oldPrice: Float
    
    func computePortfolio() -> PortfolioType {
        let unitsBoughtAtPrice = ((1.0 / oldPrice) * moneySpent)
        
        let valueAtCurentRate = unitsBoughtAtPrice * currectPrice
        
        let difference = (currectPrice - oldPrice) * unitsBoughtAtPrice
        guard difference != 0.0 else {
            return .neutral
        }
        return difference > 0 ?
            .profit(amount: difference, currentValue: valueAtCurentRate)
            : .loss(amount: -difference, currentValue: valueAtCurentRate)
    }
}

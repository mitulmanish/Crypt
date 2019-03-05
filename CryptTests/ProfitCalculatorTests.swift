//
//  ProfitCalculatorTests.swift
//  CryptTests
//
//  Created by Mitul Manish on 5/3/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//
@testable import Crypt
import XCTest

class ProfitCalculatorTests: XCTestCase {

    func testProfitScenario() {
        let calculator = ProfitCalculator(moneySpent: 1000, currectPrice: 1500, oldPrice: 500)
        let result = calculator.computePortfolio()
        
        switch result {
        case .profit(let amount, let currentValue):
            XCTAssertEqual(amount, 2000)
            XCTAssertEqual(currentValue, 3000)
        default:
            XCTFail("Expected to return a Profit")
        }
    }
    
    func testLossScenario() {
        let calculator = ProfitCalculator(moneySpent: 1000, currectPrice: 500, oldPrice: 1500)
        let result = calculator.computePortfolio()
        
        switch result {
        case .loss(let amount, let currentValue):
            XCTAssertEqual(amount, 666.6667)
            XCTAssertEqual(currentValue, 333.33334)
        default:
            XCTFail("Expected to return a Loss")
        }
    }
    
    func testNeutralScenario() {
        let calculator = ProfitCalculator(moneySpent: 1000, currectPrice: 500, oldPrice: 500)
        let result = calculator.computePortfolio()
        
        switch result {
        case .neutral:
            break
        default:
            XCTFail("Expected to return Neutral")
        }
    }
}

//
//  DecodingOperation.swift
//  Crypt
//
//  Created by Mitul Manish on 5/4/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import Foundation

protocol DecodingDataProvider: class {
    var data: Data? { get }
}

protocol DecodableOperationType: class {
    associatedtype DataType: Decodable
    associatedtype Provider: DecodingDataProvider
}

class DecodingOperation<Element, DataProvider>: BasicOperation, DecodableOperationType
where Element: Decodable, DataProvider: DecodingDataProvider {
    
    typealias Provider = DataProvider
    typealias DataType = Element
    
    private(set) var decodedObject: DataType?
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func main() {
        guard let dataToDecode = (dependencies.first { $0 is Provider } as? Provider)?.data else {
            setFinished()
            return
        }
        do {
            decodedObject = try JSONDecoder().decode(DataType.self, from: dataToDecode)
            setFinished()
        } catch {
            setFinished()
        }
    }
}

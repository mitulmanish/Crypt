//
//  NetworkOpeartion.swift
//  Crypt
//
//  Created by Mitul Manish on 21/10/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//

import Foundation

protocol DecodableOperationType: class {
    associatedtype T: Decodable
}

class DecodingOperation<Element>: BasicOperation, DecodableOperationType where Element: Decodable {
    typealias T = Element
    private(set) var decodedObject: T?

    override var isAsynchronous: Bool {
        return true
    }

    override func main() {
        let dataToDecode = (dependencies.first { $0 is DecodingDataProvider } as? DecodingDataProvider)?.data
        decodedObject = try? JSONDecoder().decode(T.self, from: dataToDecode ?? Data())
        setFinished()
    }
}

protocol DecodingDataProvider: class {
    var data: Data? { get }
}

class NetworkOperation: BasicOperation, DecodingDataProvider {
    private let session: URLSession
    private let urlRequest: URLRequest
    
    private (set) var data: Data?
    private (set) var error: Error?

    override var isAsynchronous: Bool {
        return true
    }
    
    init(session: URLSession, urlRequest: URLRequest) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    override func main() {
        session.getData(request: urlRequest) { [weak self] networkResult in
            guard let self = self else { return }
            switch networkResult {
            case .success(let data):
                self.data = data
                self.setFinished()
            case .error(let cause):
                self.error = cause
                self.setFinished()
            case .unexpected:
                self.data = nil
                self.error = nil
                self.setFinished()
            }
        }
    }
}

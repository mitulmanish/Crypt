//
//  NetworkOpeartion.swift
//  Crypt
//
//  Created by Mitul Manish on 21/10/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//

import Foundation

class NetworkOperation: BasicOperation, DecodingDataProvider {
    private let session: URLSession
    private let urlRequest: URLRequest
    
    private (set) var data: Data?
    private (set) var error: Error?

    override var isAsynchronous: Bool {
        return true
    }
    
    init(urlRequest: URLRequest, session: URLSession = URLSession(configuration: .default)) {
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
                self.data = .none
                self.error = .none
                self.setFinished()
            }
        }
    }
}

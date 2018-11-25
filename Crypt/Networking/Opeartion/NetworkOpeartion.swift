//
//  NetworkOpeartion.swift
//  Crypt
//
//  Created by Mitul Manish on 21/10/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//

import Foundation

class NetworkOperation: AsyncOperation {
    private let session: URLSession
    private let urlRequest: URLRequest
    
    var serverData: Data?
    var errorReason: String?
    
    init(session: URLSession, urlRequest: URLRequest) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    override func main() {
        session.getData(request: urlRequest) { [weak self] (networkResult) in
            guard let self = self else { return }
            switch networkResult {
            case .success(let data):
                self.serverData = data
                self.state = .finished
                self.completionBlock?()
            case .error(let reason):
                self.errorReason = reason
                self.state = .finished
                self.completionBlock?()
            case .unexpected:
                self.serverData = nil
                self.errorReason = "unexpected error"
                self.state = .finished
                self.completionBlock?()
            }
        }
    }
}

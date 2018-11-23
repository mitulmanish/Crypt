//
//  NetworkOpeartion.swift
//  Crypt
//
//  Created by Mitul Manish on 21/10/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//

import Foundation

class NetworkOperation: BasicOperation {
    private let session: URLSession
    private let urlRequest: URLRequest
    
    var serverData: Data?
    var errorReason: String?
    
    override var isAsynchronous: Bool {
        return true
    }
    
    init(session: URLSession, urlRequest: URLRequest) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    override func main() {
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        executing(true)
        finish(false)
        
        session.getData(request: urlRequest) { [weak self] (networkResult) in
            guard let self = self else { return }
            switch networkResult {
            case .success(let data):
                self.serverData = data
                self.executing(false)
                self.finish(true)
            case .error(let reason):
                self.errorReason = reason
                self.executing(false)
                self.finish(true)
            case .unexpected:
                self.serverData = nil
                self.errorReason = "unexpected error"
                self.executing(false)
                self.finish(true)
            }
        }
    }
}

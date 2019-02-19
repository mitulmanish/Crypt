//
//  BasicOpeartion.swift
//  Crypt
//
//  Created by Mitul Manish on 21/10/18.
//  Copyright © 2018 Mitul Manish. All rights reserved.
//
// adapted from: https://agostini.tech/2017/07/30/understanding-operation-and-operationqueue-in-swift/

import Foundation

class BasicOperation: Operation {

    enum State: String {
        case ready, executing, finished

        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }

    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }

        didSet {
            willChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isReady: Bool {
        return super.isReady && state == .ready
    }

    override var isFinished: Bool {
        return state == .finished
    }

    func setExecuting() {
        state = .executing
    }
    
    func setFinished() {
        state = .finished
    }

    override func start() {
        if isCancelled {
            setFinished()
            return
        }
        main()
        setExecuting()
    }

    override func cancel() {
        super.cancel()
        state = .finished
    }
}

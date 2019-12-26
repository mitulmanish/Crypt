import Foundation
struct AllCoinsNetworkOperationManager {

    func allCoins(completionHandler: @escaping (CoinCollection?) -> ()) {
        guard let request = RequestFactory.getRequest(endpointType: EndPointConstructor.allCoins) else {
            completionHandler(nil)
            return
        }
        let allCoinsOperation = NetworkOperation(urlRequest: request)
        let dataDecodingOperation = DecodingOperation<CoinCollection, NetworkOperation>()
        dataDecodingOperation.addDependency(allCoinsOperation)
        let operationQueue = OperationQueue()
        operationQueue.addOperations([allCoinsOperation, dataDecodingOperation], waitUntilFinished: false)

        dataDecodingOperation.completionBlock = {
            completionHandler(dataDecodingOperation.decodedObject ?? nil)
        }
    }
}

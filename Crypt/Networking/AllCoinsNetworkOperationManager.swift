import Foundation
struct AllCoinsNetworkOperationManager {

    func getAllCoins(completionHandler: @escaping (CoinCollection?) -> ()) {
        guard let request = RequestFactory.getRequest(endpointType: EndPointConstructor.allCoins) else {
            completionHandler(nil)
            return
        }
        let allCoinsOPeration = NetworkOperation(session: URLSession(configuration: .default), urlRequest: request)
        let dataDecodingOperation = DecodingOperation<CoinCollection>()
        dataDecodingOperation.addDependency(allCoinsOPeration)
        let operationQueue = OperationQueue()
        operationQueue.addOperations([allCoinsOPeration, dataDecodingOperation], waitUntilFinished: false)

        dataDecodingOperation.completionBlock = {
            completionHandler(dataDecodingOperation.decodedObject ?? nil)
        }
    }
}

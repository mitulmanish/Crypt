import Foundation

struct RequestFactory {
    static func getHistoricalDataRequest(endpointType: EndPointConstructor) -> URLRequest? {
        guard let baseURL = URL(string: "https://www.cryptocurrencychart.com/api") else {
            return nil
        }
        var request = URLRequest(url: baseURL)
        request.setValue("2108fd7dcca54a7828d81f43f0cffcf4", forHTTPHeaderField: "Key")
        request.setValue("46cfa4841c7fef71472d793966f156e5", forHTTPHeaderField: "Secret")
        request.url?.appendPathComponent(endpointType.formattedEndpoint)
        return request
    }
}

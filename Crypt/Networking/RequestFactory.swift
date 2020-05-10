import Foundation

struct RequestFactory {
    static func getRequest(endpointType: EndPointConstructor) -> URLRequest? {
        let userDeafault = UserDefaults()
        guard
            let apiKey = userDeafault.string(forKey: UserDefaults.apiKeyPath),
            let apiSecret = userDeafault.string(forKey: UserDefaults.apiSecretPath),
            let baseURL = URL(string: "https://www.cryptocurrencychart.com/api/") else {
            return nil
        }
        var request = URLRequest(url: baseURL)
        request.setValue(apiKey, forHTTPHeaderField: "Key")
        request.setValue(apiSecret, forHTTPHeaderField: "Secret")
        request.url?.appendPathComponent(endpointType.formattedEndpoint)
        return request
    }
}

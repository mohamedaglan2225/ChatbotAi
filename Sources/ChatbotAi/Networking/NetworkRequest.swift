//
//  File.swift
//  
//
//  Created by Mohamed Aglan on 5/31/24.
//

import Foundation

protocol NetworkRequest {
    var url: URL { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var queryParameters: [String: String]? { get }
}

extension NetworkRequest {
    func urlWithQueryParameters() -> URL {
        guard let queryParameters = queryParameters, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return url
        }
        urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return urlComponents.url ?? url
    }
}

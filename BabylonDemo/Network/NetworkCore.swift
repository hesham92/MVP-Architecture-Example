//
//  NetworkCore.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/14/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

protocol TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HttpMethod { get }
    var jsonParameters: [String: Any] { get }
    var headers: [String: String]? { get }
}

enum Result<ModelType: Decodable> {
    case failure(Error)
    case success(ModelType)
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension TargetType {
    func urlRequest() -> URLRequest {
        // generate url
        let urlPath = [self.baseURL.absoluteString, self.path].joined()
        let url = URL(string: urlPath)!

        var request = URLRequest(url: url)

        /// http method
        request.httpMethod = self.method.rawValue

        /// body
        switch self.method {
        case .get: break
        default:
            request.httpBody = try? JSONSerialization.data(withJSONObject: self.jsonParameters, options: [])
        }

        /// headers
        self.headers?.forEach { it in
            request.addValue(it.value, forHTTPHeaderField: it.key)
        }

        return request
    }
}

class HttpService<Target: TargetType> {

    private var requestClosure: (Target) -> URLRequest
    private var session: URLSession

    init(
        configuration: URLSessionConfiguration = URLSessionConfiguration.default,
        requestClosure: @escaping ((Target) -> URLRequest) = { $0.urlRequest() }
        ) {
        self.session = URLSession(configuration: configuration)
        self.requestClosure = requestClosure
    }

    @discardableResult func request<ModelType: Decodable>(_ endpoint: Target, modelType: ModelType.Type, responseData: @escaping (Result<ModelType>) -> Void) -> URLSessionDataTask {
        let request = requestClosure(endpoint)

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                responseData(Result.failure(error!))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ModelType.self, from: data)
                responseData(Result.success(result))
            } catch {
                responseData(Result.failure(error))
            }

        }
        task.resume()

        return task
    }
}

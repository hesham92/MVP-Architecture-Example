//
//  NetworkCore.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/14/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

protocol EndpointType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HttpMethod { get }
    var jsonParameters: [String: Any] { get }
    var headers: [String: String]? { get }
    func urlRequest() -> URLRequest
}

enum Result<ModelType> {
    case failure(Error)
    case success(ModelType)
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension EndpointType {
    func urlRequest() -> URLRequest {
        let urlPath = [self.baseURL.absoluteString, self.path].joined()
        let url = URL(string: urlPath)!

        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue

        //TODO: Handle post types
        switch self.method {
        case .get: break
        default:
            request.httpBody = try? JSONSerialization.data(withJSONObject: self.jsonParameters, options: [])
        }

        self.headers?.forEach { it in
            request.addValue(it.value, forHTTPHeaderField: it.key)
        }

        return request
    }
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

class HttpService<Endpoint: EndpointType> {

    private var session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func request<ModelType: Codable>(_ endpoint: Endpoint, modelType: ModelType.Type, responseData: @escaping (Result<ModelType>) -> Void) {
        let request = endpoint.urlRequest()

        let task = session.dataTask(with: request) { data, _, error in
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
    }
}

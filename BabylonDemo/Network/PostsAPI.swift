//
//  APIManager.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/15/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import Foundation

enum PostsAPI {
    case getPosts
}

extension PostsAPI: TargetType {
    var baseURL: URL { return URL(string: "https://jsonplaceholder.typicode.com")! }

    var path: String {
        switch self {
        case .getPosts:
            return "/posts"
        }
    }

    var method: HttpMethod {
        switch self {
        case .getPosts:
            return .get
        }
    }

    var jsonParameters: [String: Any] {
        return [:]
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

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
    case getAuthor(userId: Int)
    case getComments(postId: Int)
}

extension PostsAPI: TargetType {
    var baseURL: URL { return URL(string: "https://jsonplaceholder.typicode.com")! }

    var path: String {
        switch self {
        case .getPosts:
            return "/posts"
        case .getAuthor(let userId):
            return "/users?id=\(userId)"
        case .getComments(let postId):
            return "/comments?postId=\(postId)"
        }
    }

    var method: HttpMethod {
        switch self {
        case .getPosts:
            return .get
        case .getAuthor(_):
            return .get
        case .getComments(_):
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

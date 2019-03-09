//
//  PostsProvider.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/28/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import Foundation

protocol PostsProviderProtocol {
    var cache: ReadOnlyCache { get }
    func getPosts(completion: @escaping (Result<[Post]>) -> ())
    func getAuthor(userId: Int, completion: @escaping (Result<Author>) -> ())
    func getComments(postId: Int, completion: @escaping (Result<[Comment]>) -> ())
}

enum PostsProviderError: Error {
    case emptyUserResult
}

class PostsProvider: PostsProviderProtocol {
    private let completionQueue: DispatchQueue
    private var _cache: Cache
    private let api: HttpService<PostsAPI>

    init(completionQueue: DispatchQueue = .main, cache: Cache = RealmCache(), api: HttpService<PostsAPI> = HttpService<PostsAPI>()) {
        self.completionQueue = completionQueue
        self._cache = cache
        self.api = api
    }

    var cache: ReadOnlyCache {
        return _cache
    }

    func getPosts(completion: @escaping (Result<[Post]>) -> ()) {
        api.request(.getPosts, modelType: [Post].self) { result in
            self.completionQueue.async {
                completion(result)
            }

            // cache Posts
            if case let Result.success(posts) = result {
                self._cache.posts = posts
            }
        }
    }

    func getAuthor(userId: Int, completion: @escaping (Result<Author>) -> ()) {
        api.request(.getAuthor(userId: userId), modelType: [Author].self) { result in
            self.completionQueue.async {
                switch result {
                case .success(let authors):
                    if let author = authors.first {
                        completion(.success(author))
                    } else {
                        completion(.failure(PostsProviderError.emptyUserResult))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }

            // cache author
            if case let Result.success(authors) = result, let author = authors.first {
                self._cache.addAuthor(author: author)
            }
        }
    }
    
    func getComments(postId: Int, completion: @escaping (Result<[Comment]>) -> ()) {
        api.request(.getComments(postId: postId), modelType: [Comment].self) { (result) in
            self.completionQueue.async {
                completion(result)
            }
            // cache Comments
            if case let Result.success(comments) = result {
                self._cache.addComments(comments: comments)
            }
        }
    }
}

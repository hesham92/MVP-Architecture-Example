//
//  PostsProvider.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/28/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import Foundation

protocol PostsProviderProtocol {
    func getPosts(completion: @escaping (Result<[Post]>) -> ())
    func getAuthor(userId: Int, completion: @escaping (Result<Author>) -> ())
    func getComments(postId: Int, completion: @escaping (Result<[Comment]>) -> ())
}

class PostsProvider: PostsProviderProtocol {
    private let completionQueue: DispatchQueue
    private var cache: Cache
    private let api: HttpService<PostsAPI>
    private var isOnline = true

    init(completionQueue: DispatchQueue = .main, cache: Cache = RealmCache(), api: HttpService<PostsAPI> = HttpService<PostsAPI>()) {
        self.completionQueue = completionQueue
        self.cache = cache
        self.api = api
    }

    func getPosts(completion: @escaping (Result<[Post]>) -> ()) {
        if isOnline {
            api.request(.getPosts, modelType: [Post].self) { result in
                self.completionQueue.async {
                    completion(result)
                }

                // cache Posts
                if case let Result.success(posts) = result {
                    self.cache.posts = posts
                }
            }
        }
        else {
            return completion(Result.success(self.cache.posts))
        }
    }

    enum Error: Swift.Error {
        case emptyUserResult
    }

    func getAuthor(userId: Int, completion: @escaping (Result<Author>) -> ()) {
        api.request(.getAuthor(userId: userId), modelType: [Author].self) { result in
            if self.isOnline {
                self.completionQueue.async {
                    switch result {
                    case .success(let authors):
                        if let author = authors.first {
                            completion(.success(author))
                        } else {
                            completion(.failure(Error.emptyUserResult))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

                // cache author
                if case let Result.success(authors) = result, let author = authors.first {
                    self.cache.addAuthor(author: author)
                }
            }
            else {
                if let author = self.cache.getAuthor(userId: userId) {
                    return completion(Result.success(author))
                }
            }
        }
    }
    
    func getComments(postId: Int, completion: @escaping (Result<[Comment]>) -> ()) {
        api.request(.getComments(postId: postId), modelType: [Comment].self) { (result) in
            if self.isOnline {
                self.completionQueue.async {
                    completion(result)
                }

                // cache Comments
                if case let Result.success(comments) = result {
                    self.cache.addComments(comments: comments)
                }
            }
            else {
                if let comments = self.cache.getComments(postId: postId) {
                    return completion(Result.success(comments))
                }
            }
        }
    }
}

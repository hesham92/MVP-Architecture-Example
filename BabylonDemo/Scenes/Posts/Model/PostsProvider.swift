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
    private var completionQueue: DispatchQueue

    init(completionQueue: DispatchQueue = .main) {
        self.completionQueue = completionQueue
    }

    func getPosts(completion: @escaping (Result<[Post]>) -> ()) {
        let api = HttpService<PostsAPI>()

        api.request(.getPosts, modelType: [Post].self) { (result) in
            self.completionQueue.async {
                completion(result)
            }
        }
    }

    enum Error: Swift.Error {
        case emptyUserResult
    }

    func getAuthor(userId: Int, completion: @escaping (Result<Author>) -> ()) {
        let api = HttpService<PostsAPI>()

        api.request(.getAuthor(userId: userId), modelType: [Author].self) { (result) in
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
        }
    }
    
    func getComments(postId: Int, completion: @escaping (Result<[Comment]>) -> ()) {
        let api = HttpService<PostsAPI>()

        api.request(.getComments(postId: postId), modelType: [Comment].self) { (result) in
            self.completionQueue.async {
                completion(result)
            }
        }
    }
}

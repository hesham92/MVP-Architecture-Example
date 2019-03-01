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
}

class PostsProvider: PostsProviderProtocol {
    func getPosts(completion: @escaping (Result<[Post]>) -> ()) {
        let api = HttpService<PostsAPI>()

        api.request(.getPosts, modelType: [Post].self) { (result) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

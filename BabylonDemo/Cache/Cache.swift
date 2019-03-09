//
//  Cache.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/2/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import Foundation

protocol ReadOnlyCache {
    var posts: [Post] { get }
    func getAuthor(userId: Int) -> Author?
    func getComments(postId: Int) -> [Comment]?
}


protocol Cache: ReadOnlyCache {
    var posts: [Post] { get set }
    func addAuthor(author: Author)
    func addComments(comments: [Comment])
}

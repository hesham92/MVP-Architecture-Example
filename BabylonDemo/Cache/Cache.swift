//
//  Cache.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/2/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import Foundation

protocol Cache {
    var posts: [Post] { get set }
    func getAuthor(userId: Int) -> Author?
    func addAuthor(author: Author)
    func getComments(postId: Int) -> [Comment]?
    func addComments(comments: [Comment])
}

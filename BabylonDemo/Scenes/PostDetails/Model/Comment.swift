//
//  Comment.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/2/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

struct Comment: Codable, Equatable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}

//
//  Post.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/15/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

struct Post: Codable, Equatable {
    let title: String
    let id: Int
    let body: String
    let userId: Int
}

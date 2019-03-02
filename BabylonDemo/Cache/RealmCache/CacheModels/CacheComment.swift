//
//  CacheComment.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/2/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import RealmSwift

class CacheComment: Object {
    @objc dynamic var id = 0
    @objc dynamic var postId = 0
    @objc dynamic var name = ""
    @objc dynamic var email = ""
    @objc dynamic var body = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    var comment: Comment {
        return Comment(id: id, postId: postId, name: name, email:email, body: body)
    }
}

extension Comment {
    var cacheComment: CacheComment {

        let comment = CacheComment()
        comment.id = id
        comment.postId = postId
        comment.body = body
        comment.email = email
        comment.name = name

        return comment
    }
}


//
//  RealmCache.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/2/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCache: Cache {

    private var realm: Realm { return try! Realm() }

    var posts: [Post] {
        get {
            return realm.objects(CachePost.self).map({ $0.post })
        }

        set {
            try? realm.write {
                realm.add(newValue.map({ $0.cachePost }), update: true)
            }
        }
    }

    func getComments(postId: Int) -> [Comment]? {
        return realm.objects(CacheComment.self).map({ $0.comment })
    }

    func addComments(comments: [Comment]) {
        try? realm.write {
            realm.add(comments.map({ $0.cacheComment }), update: true)
        }
    }

    func getAuthor(postId userId: Int) -> Author? {
        return realm.object(ofType: CacheAuthor.self, forPrimaryKey: userId)?.author
    }

    func addAuthor(author: Author) {
        try? realm.write {
            realm.add(author.cacheAuthor, update: true)
        }
    }
}

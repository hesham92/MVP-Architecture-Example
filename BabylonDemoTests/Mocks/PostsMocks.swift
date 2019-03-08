//
//  PostsMocks.swift
//  BabylonDemoTests
//
//  Created by Hesham Mohamed on 12/28/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import Foundation
@testable import BabylonDemo

class PostsViewMock: PostsViewProtocol, LoadingViewShowing, ErrorViewShowing {
    var didShowLoading = false
    var didHideLoading = false
    var didShowError = false
    var didShowPosts = false

    func showLoading() {
        didShowLoading = true
    }

    func hideLoading() {
        didHideLoading = true
    }

    func showError(_ error: Error) {
        didShowError = true
    }

    func showPosts() {
        didShowPosts = true
    }
}

class PostsProviderMock: PostsProviderProtocol {
    var postsResult: Result<[Post]>?
    var commentsResult: Result<[Comment]>?
    var authorResult: Result<Author>?

    func getAuthor(userId: Int, completion: @escaping (Result<Author>) -> ()) {

    }

    func getComments(postId: Int, completion: @escaping (Result<[Comment]>) -> ()) {

    }

    func getPosts(completion: @escaping (Result<[Post]>) -> ()) {
        completion(postsResult!)
    }
}

class PostCellMock: PostCell {
    var postTitle: String?
}

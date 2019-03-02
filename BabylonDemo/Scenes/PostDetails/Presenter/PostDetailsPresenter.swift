//
//  PostDetailsPresenter.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/2/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import UIKit

class PostDetailsPresenter: PostDetailsPresenterProtocol {
    typealias PostDetailsView = PostDetailsViewProtocol & LoadingViewShowing & ErrorViewShowing
    private weak var view: PostDetailsView?
    private weak var navigator: AppNavigator!
    private var postsProvider: PostsProviderProtocol
    private(set) var post: Post
    private(set) var author: Author?
    private(set) var comments: [Comment] = []
    private var dispatchGroup = DispatchGroup()

    init(post: Post, view: PostDetailsView, navigator: AppNavigator = .shared, postsProvider: PostsProviderProtocol = PostsProvider()) {
        self.view = view
        self.navigator = navigator
        self.postsProvider = postsProvider
        self.post = post
    }

    enum Error: Swift.Error {
        case noResultFound
    }

    func viewDidLoad() {
        self.view?.showLoading()

        var authorResult: Result<Author> = .failure(Error.noResultFound)
        var commentsResult: Result<[Comment]> = .failure(Error.noResultFound)

        dispatchGroup.enter()
        postsProvider.getAuthor(userId: post.id) {[weak self] (result) in
            guard let self = self else { return }
            self.dispatchGroup.leave()
            authorResult = result
        }

        dispatchGroup.enter()
        postsProvider.getComments(postId: post.id) {[weak self] (result) in
            guard let self = self else { return }
            self.dispatchGroup.leave()
            commentsResult = result
        }

        dispatchGroup.notify(queue: .main) {[weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            switch (authorResult, commentsResult) {
            case (.success(let author), .success(let comments)):
                self.author = author
                self.comments = comments
                self.view?.showPostDetails(authorName: self.author?.name ?? "", commentsCount: self.comments.count, postBody: self.post.body)
                break
            case (.failure(let authorError), _):
                self.view?.showError(authorError)
                break
            case (_, .failure(let commentsError)):
                self.view?.showError(commentsError)
                break
            }
        }
    }
}

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
    private var networkError: NetworkError? = nil

    init(post: Post, view: PostDetailsView, navigator: AppNavigator = .shared, postsProvider: PostsProviderProtocol = PostsProvider()) {
        self.view = view
        self.navigator = navigator
        self.postsProvider = postsProvider
        self.post = post
        self.addInternetObservers()
    }

    enum Error: Swift.Error {
        case noResultFound
    }

    @objc private func handleInternetStatus(notification: NSNotification){
        if let online = notification.userInfo?[InternetConnection.Keys.InternetStatus] as? Bool {
            if online {
                if networkError != nil {
                    self.networkError = nil
                    self.getPostDetails()
                }
            }
        }
    }

    func addInternetObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleInternetStatus),
            name: .InternetStatus,
            object: nil)
    }

    private func getPostDetails() {
        var authorResult: Result<Author> = .failure(Error.noResultFound)
        var commentsResult: Result<[Comment]> = .failure(Error.noResultFound)

        dispatchGroup.enter()
        postsProvider.getAuthor(postId: post.id) {[weak self] (result) in
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
            case (.failure(let error), _):
                if let error = NetworkError(error: error), error == .noInternet {
                    self.networkError = error
                    if let author = self.postsProvider.cache.getAuthor(postId: self.post.id) { // to make sure that is there cached post to show
                        self.author = author
                        self.comments = self.postsProvider.cache.getComments(postId: self.post.id) ?? []
                        self.view?.showPostDetails(authorName: author.name, commentsCount: self.comments.count, postBody: self.post.body)
                    }

                }
                self.view?.showError(error)
                break
            case (_, .failure(let error)):
                self.view?.showError(error)
                break
            }
        }
    }

    func viewDidLoad() {
        self.view?.showLoading()
        self.getPostDetails()
    }
}

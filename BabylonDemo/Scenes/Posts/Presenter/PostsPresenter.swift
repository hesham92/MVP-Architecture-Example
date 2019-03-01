//
//  PostsPresenter.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/15/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

class PostsPresenter: PostsPresenterProtocol {

    typealias PostsView = PostsViewProtocol & LoadingViewShowing & ErrorViewShowing
    private weak var view: PostsView?
    private weak var navigator: AppNavigator!
    private var postsProvider: PostsProviderProtocol
    private(set) var posts: [Post] = []

    init(view: PostsView, navigator: AppNavigator = .shared, postsProvider: PostsProviderProtocol = PostsProvider()) {
        self.view = view
        self.navigator = navigator
        self.postsProvider = postsProvider
    }

    var postsCount: Int {
        return posts.count
    }

    func viewDidLoad() {
        self.view?.showLoading()

        self.postsProvider.getPosts { [weak self] (result) in
            guard let self = self else { return }
            self.view?.hideLoading()

            switch(result) {
            case .success(let posts):
                self.posts = posts
                self.view?.showPosts()
            case .failure(let error):
                self.view?.showError(error)
            }
        }
    }

    func configureCell(_ cell: PostCell, atIndexPath indexPath: IndexPath) {
        let post = posts[indexPath.row]

        cell.postTitle = post.title
    }

    func didSelectPostAtIndexPath(_ indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        navigator.navigate(to: .photoViewController(post: post))
    }
}

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
    private var networkError: NetworkError? = nil
    private var notificationCenter: NotificationCenter


    init(view: PostsView, navigator: AppNavigator = .shared, postsProvider: PostsProviderProtocol = PostsProvider(), notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.view = view
        self.navigator = navigator
        self.postsProvider = postsProvider
        self.notificationCenter = notificationCenter
        self.addInternetObservers()
    }

    @objc private func handleInternetStatus(notification: NSNotification){
        if let online = notification.userInfo?[InternetConnection.Keys.InternetStatus] as? Bool {
            if online {
                if networkError != nil {
                    self.networkError = nil
                    self.getPosts()
                }
            }
        }
    }

    func addInternetObservers() {
        notificationCenter.addObserver(
            self,
            selector: #selector(self.handleInternetStatus),
            name: .InternetStatus,
            object: nil)
    }

    var postsCount: Int {
        return posts.count
    }

    func viewDidLoad() {
        self.getPosts()
    }

    private func getPosts() {
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

                if let error = NetworkError(error: error), error == .noInternet {
                    self.networkError = error
                    self.posts = self.postsProvider.cache.posts
                    self.view?.showPosts()
                }
            }
        }
    }

    func configureCell(_ cell: PostCell, atIndexPath indexPath: IndexPath) {
        let post = posts[indexPath.row]
        cell.postTitle = post.title
    }

    func didSelectPostAtIndexPath(_ indexPath: IndexPath) {
        let post = posts[indexPath.row]
        navigator.navigate(to: .postDetailsViewController(post: post))
    }
}

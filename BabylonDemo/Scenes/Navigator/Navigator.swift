//
//  Navigator.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/17/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

protocol Navigator: class {
    associatedtype Destination

    func navigate(to destination: Destination)
}

class AppNavigator: Navigator {
    private weak var window: UIWindow?
    private var navigationController: UINavigationController?
    static let shared = AppNavigator()

    enum Destination {
        case postDetailsViewController(post: Post)
    }

    func navigate(to destination: Destination) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func start(window: inout UIWindow?) {
        window = UIWindow(frame: UIScreen.main.bounds)
        navigationController = PostsViewController.navigationController()
        let postsVC = navigationController?.topViewController as! PostsViewController
        postsVC.presenter = PostsPresenter(view: postsVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        self.window = window
    }

    private func makeViewController(for destination: Destination) -> UIViewController {
        switch destination {
        case .postDetailsViewController(let post):
            let postDetailsViewController = PostDetailsViewController.newController()
            let postDetailsPresenter = PostDetailsPresenter(post: post, view: postDetailsViewController)
            postDetailsViewController.presenter = postDetailsPresenter
            return postDetailsViewController
        }
    }
}

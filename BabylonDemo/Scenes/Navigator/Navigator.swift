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

    static let shared = AppNavigator()

    enum Destination {
        case photoViewController(post: Post)
    }

    private weak var window: UIWindow?
    private var navigationController: UINavigationController?

    // MARK: - Navigator
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

    // MARK: - Private
    private func makeViewController(for destination: Destination) -> UIViewController {
        return UIViewController()
       /* switch destination {
        case .photoViewController(let post):
            let photosViewController = PhotosViewController.newController()
            let photosPresenter = PhotosPresenter(post: post, view: photosViewController)
            photosViewController.presenter = photosPresenter
            return photosViewController
        }
 */
    }
}

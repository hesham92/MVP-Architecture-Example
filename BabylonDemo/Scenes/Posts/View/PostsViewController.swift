//
//  PostsViewController.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/15/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

class PostsViewController: UIViewController, LoadingViewShowing, ErrorViewShowing {
    
    //MARK: - Outlets
   @IBOutlet private weak var postsTableView: UITableView!

    //MARK: - Properties
    var presenter: PostsPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }

    class func navigationController() -> UINavigationController {
        return R.storyboard.posts.instantiateInitialViewController()!
    }
}

extension PostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.postsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.postTableViewCell, for: indexPath)!

        cell.accessibilityIdentifier = "MyCell_\(indexPath.row)"

        presenter.configureCell(cell, atIndexPath: indexPath)

        return cell
    }
}


extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectPostAtIndexPath(indexPath)
    }
}

extension PostsViewController: PostsViewProtocol {

    func showPosts() {
        self.postsTableView.reloadData()
    }
}

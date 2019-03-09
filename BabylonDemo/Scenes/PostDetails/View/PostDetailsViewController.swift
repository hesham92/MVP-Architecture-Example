//
//  PostDetailsViewController.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/2/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import UIKit

class PostDetailsViewController: UIViewController, ErrorViewShowing, LoadingViewShowing {
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!

    var presenter: PostDetailsPresenter!

    class func newController() -> PostDetailsViewController {
        return R.storyboard.postDetails.postDetailsViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
}

extension PostDetailsViewController: PostDetailsViewProtocol {
    func showPostDetails(authorName: String, commentsCount: Int, postBody: String) {
        self.authorNameLabel.text = "Author: " + authorName
        self.commentsCountLabel.text = "Comments Count: " + String(commentsCount)
        self.descriptionLabel.text = "Description: " + postBody
    }
}

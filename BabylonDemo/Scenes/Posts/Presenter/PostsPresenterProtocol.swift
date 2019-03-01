//
//  PostsPresenterProtocol.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/28/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

protocol PostsPresenterProtocol: class {
    var postsCount: Int { get }
    func viewDidLoad()
    func configureCell(_ cell: PostCell, atIndexPath indexPath: IndexPath)
    func didSelectPostAtIndexPath(_ indexPath: IndexPath)
}

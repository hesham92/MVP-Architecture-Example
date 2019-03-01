//
//  PostsViewProtocol.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/15/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

protocol PostsViewProtocol: class {
    func showPosts()
}

protocol PostCell: class {
    var postTitle: String? { get set }
}

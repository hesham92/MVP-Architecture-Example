//
//  PostDetailsViewMock.swift
//  BabylonDemoTests
//
//  Created by Hesham Mohamed on 3/9/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import Foundation
@testable import BabylonDemo

class PostDetailsViewMock: PostDetailsViewProtocol, LoadingViewShowing, ErrorViewShowing {

    var didShowLoading = false
    var didHideLoading = false
    var didShowError = false
    var didShowPostDetails = false

    func showLoading() {
        didShowLoading = true
    }

    func hideLoading() {
        didHideLoading = true
    }

    func showError(_ error: Error) {
        didShowError = true
    }

    func showPostDetails(authorName: String, commentsCount: Int, postBody: String) {
        didShowPostDetails = true
    }
}


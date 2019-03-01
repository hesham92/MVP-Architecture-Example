//
//  LoadViewShowing.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/26/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

protocol LoadingViewShowing: class {
    func showLoading()
    func hideLoading()
}

fileprivate var loadingViewControllerKey = "loadingViewControllerKey"

extension LoadingViewShowing where Self: UIViewController {

    /// Simulate stored property.
    var loadingViewController: LoadingViewController? {
        get {
            return objc_getAssociatedObject(self, &loadingViewControllerKey) as? LoadingViewController
        }

        set {
            objc_setAssociatedObject(self, &loadingViewControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func showLoading() {
        guard loadingViewController == nil else { return }
        loadingViewController = LoadingViewController()
        loadingViewController?.addInParent(self)
    }

    func hideLoading() {
        loadingViewController?.remove()
        loadingViewController = nil
    }
}

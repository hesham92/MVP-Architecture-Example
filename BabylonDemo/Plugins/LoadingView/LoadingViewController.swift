//
//  Loading.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 12/23/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    private lazy var activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.activityIndicator.startAnimating()
    }
    
    func setupViews() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalTo: view.widthAnchor),
            activityIndicator.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        
    }
    
    func addInParent(_ parent: UIViewController) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        parent.addChild(self)
        parent.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: parent.view.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: parent.view.centerYAnchor)
            ])
        
        didMove(toParent: parent)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

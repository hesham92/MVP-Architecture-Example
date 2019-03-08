//
//  InternetConnection.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/8/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import Foundation
import Reachability

class InternetConnection {
    static let shared = InternetConnection()
    let reachability = Reachability()!

    struct Keys {
        static let InternetStatus = "InternetStatus"
    }

    init() {}

    func setObservers() -> Void {
        reachability.whenReachable = { _ in
            NotificationCenter.default.post(name: .InternetStatus, object: nil, userInfo: [Keys.InternetStatus: true])
            print("Reachable now")
        }

        reachability.whenUnreachable = { _ in
            NotificationCenter.default.post(name: .InternetStatus, object: nil, userInfo: [Keys.InternetStatus: false])
            print("Not Reachable")
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

extension Notification.Name {
    static let InternetStatus = Notification.Name("InternetStatus")
}

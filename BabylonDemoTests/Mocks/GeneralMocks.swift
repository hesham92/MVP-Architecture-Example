//
//  GeneralMocks.swift
//  BabylonDemoTests
//
//  Created by Hesham Mohamed on 12/29/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import Foundation
@testable import BabylonDemo

class MockAppNavigator: AppNavigator {
    var destination: Destination?

    override func navigate(to destination: AppNavigator.Destination) {
        self.destination = destination
    }
}

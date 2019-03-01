//
//  IntegrationTests.swift
//  BabylonDemoIntegrationTests
//
//  Created by Hesham Mohamed on 12/29/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import XCTest
@testable import BabylonDemo

class IntegrationTests: XCTestCase {

    private var postsProvider: PostsProviderProtocol!

    override func setUp() {
        postsProvider = PostsProvider()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetPostsAPI() {
        let expect = expectation(description: "")

        self.postsProvider.getPosts { (result) in
            expect.fulfill()
            switch(result) {
            case .success(let posts):
                print(posts)
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 30) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
}

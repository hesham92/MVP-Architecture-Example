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


    func testGetAuthorInfoAPI() {
        let expect = expectation(description: "")

        self.postsProvider.getAuthor(userId: 1) { (result) in
            expect.fulfill()
            switch(result) {
            case .success(let author):
                print(author)
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 30) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }


    func testGetPostCommentsAPI() {
        let expect = expectation(description: "")

        self.postsProvider.getComments(postId: 1) { (result) in
            expect.fulfill()
            switch(result) {
            case .success(let comments):
                print(comments)
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

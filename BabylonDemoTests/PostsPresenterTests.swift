//
//  PostsPresenterTests.swift
//  BabylonDemoTests
//
//  Created by Hesham Mohamed on 12/28/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import XCTest
@testable import BabylonDemo

class PostsPresenterTests: XCTestCase {

    private var presenter: PostsPresenter!
    private var view: PostsViewMock!
    private var postsProvider: PostsProviderMock!
    private var navigator: MockAppNavigator!
    private let posts = [Post(title: "Alb1", id: 1, body: "body1", userId: 1), Post(title: "Alb2", id: 2, body: "body2", userId: 1)]

    override func setUp() {

        view = PostsViewMock()
        postsProvider = PostsProviderMock()
        navigator = MockAppNavigator()
        presenter = PostsPresenter(view: view, navigator: navigator, postsProvider: postsProvider)
    }

    override func tearDown() {
        presenter = nil
        view = nil
        postsProvider = nil
        navigator = nil
    }

    func testViewDidLoadSuccess() {

        postsProvider.postsResult = .success(posts)
        presenter.viewDidLoad()

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPosts)
        XCTAssertFalse(view.didShowError)
        XCTAssertEqual(posts, presenter.posts)
        XCTAssertEqual(presenter.postsCount, posts.count)
    }

    func testViewDidLoadFailure() {
        struct MockError: Error {}
        let error = MockError()

        postsProvider.postsResult = .failure(error)
        presenter.viewDidLoad()

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertFalse(view.didShowPosts)
        XCTAssertTrue(view.didShowError)
    }

    func testConfigureCell() {
        postsProvider.postsResult = .success(posts)
        presenter.viewDidLoad()

        let postCellMock = PostCellMock()
        let indexPath = IndexPath(row: 0, section: 0)

        presenter.configureCell(postCellMock, atIndexPath: indexPath)
        XCTAssertEqual(postCellMock.postTitle, posts[indexPath.row].title)
    }

    func testDidSelectPostAtIndexPath() {

        postsProvider.postsResult = .success(posts)
        presenter.viewDidLoad()

        let indexPath = IndexPath(row: 0, section: 0)
        presenter.didSelectPostAtIndexPath(indexPath)

        switch navigator.destination {

        case .postDetailsViewController(let post)?:
            XCTAssertEqual(post, posts[indexPath.row])
        default:
            XCTFail()
        }
    }

}

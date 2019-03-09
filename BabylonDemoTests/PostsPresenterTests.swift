//
//  PostsPresenterTests.swift
//  BabylonDemoTests
//
//  Created by Hesham Mohamed on 12/28/18.
//  Copyright © 2018 Hesham Mohamed. All rights reserved.
//

import XCTest
import RealmSwift
@testable import BabylonDemo

class URLSessionDataTaskMock: URLSessionDataTask {

    var action = {}

    override func resume() {
        action()
    }
}

fileprivate class URLSessionMock: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSessionDataTaskMock()
        task.action = {
            completionHandler(self.data, self.response, self.error)
        }

        return task
    }
}

class PostsPresenterTests: XCTestCase {
    private var presenter: PostsPresenter!
    private var view: PostsViewMock!
    private var postsProvider: PostsProviderProtocol!
    private var navigator: MockAppNavigator!
    private let apiPosts = [Post(title: "Alb3", id: 3, body: "body3", userId: 2), Post(title: "Alb4", id: 4, body: "body4", userId: 2)]
    private let cachedPosts = [Post(title: "Alb1", id: 1, body: "body1", userId: 1), Post(title: "Alb2", id: 2, body: "body2", userId: 1)]
    private let completionQueue = DispatchQueue(label: "CompletionQueues")
    private var urlSessionMock: URLSessionMock!
    private var httpService: HttpService<PostsAPI>!
    private var cache: RealmCache!
   // private let notificationCenter: NotificationCenter

    override func setUp() {
        view = PostsViewMock()

        urlSessionMock = URLSessionMock()
        httpService = HttpService<PostsAPI>(session: urlSessionMock)
        cache = RealmCache(realmFactory: { try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm")) } )
        postsProvider = PostsProvider(completionQueue: completionQueue, cache: cache, api: httpService)
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
        //  postsProvider.postsResult = .success(posts)
        urlSessionMock.data = try! JSONEncoder().encode(apiPosts)

        presenter.viewDidLoad()

        completionQueue.sync {
            // Just to wait for previous async calls
        }

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPosts)
        XCTAssertFalse(view.didShowError)
        XCTAssertEqual(apiPosts, presenter.posts)
        XCTAssertEqual(presenter.postsCount, apiPosts.count)
    }

    func testReconnectInternet() {
        // set cached posts
        cache.posts = cachedPosts

        // set error type to network error
        let error = NSError(domain: "", code: 0, userInfo: [NSUnderlyingErrorKey: NSError(domain: kCFErrorDomainCFNetwork as String, code: 0, userInfo: nil)])

        urlSessionMock.error = error
        presenter.viewDidLoad()
        completionQueue.sync {
            // Just to wait for previous async calls
        }

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPosts) // it's executing only when there data in cache
        XCTAssertTrue(view.didShowError)

        // simulte reconneting internet
        let internetReconnectExpectation = expectation(description: "Internet reconnects")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // prepare data after internet becoming active
            self.urlSessionMock.data = try! JSONEncoder().encode(self.apiPosts)
            self.view.didShowError = false
            NotificationCenter.default.post(name: .InternetStatus, object: nil, userInfo: [InternetConnection.Keys.InternetStatus: true])
            internetReconnectExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (_) in

        }

        // data is loaded from api successfully after reconnecting the internet
        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPosts)
        XCTAssertFalse(view.didShowError)
        XCTAssertEqual(apiPosts, presenter.posts)
        XCTAssertEqual(presenter.postsCount, apiPosts.count)
    }

    func testViewDidLoadFailureWithCachedData() {
        cache.posts = cachedPosts

        let error = NSError(domain: "", code: 0, userInfo: [NSUnderlyingErrorKey: NSError(domain: kCFErrorDomainCFNetwork as String, code: 0, userInfo: nil)])
        
        urlSessionMock.error = error
        presenter.viewDidLoad()
        completionQueue.sync {
            // Just to wait for previous async calls
        }

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPosts) // it's executing only when there data in cache
        XCTAssertTrue(view.didShowError)
    }

    func testViewDidLoadFailureWithNoCachedData() {
        cache.posts = []
        struct MockError: Error {}
        let error = MockError()

        urlSessionMock.error = error
        presenter.viewDidLoad()
        completionQueue.sync {
            // Just to wait for previous async calls
        }

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertFalse(view.didShowPosts) // There is no data in cache to show
        XCTAssertTrue(view.didShowError)
    }

    func testConfigureCell() {
        urlSessionMock.data = try! JSONEncoder().encode(apiPosts)
        presenter.viewDidLoad()
        completionQueue.sync {
            // Just to wait for previous async calls
        }

        let postCellMock = PostCellMock()
        let indexPath = IndexPath(row: 0, section: 0)

        presenter.configureCell(postCellMock, atIndexPath: indexPath)
        XCTAssertEqual(postCellMock.postTitle, apiPosts[indexPath.row].title)
    }

    func testDidSelectPostAtIndexPath() {
        urlSessionMock.data = try! JSONEncoder().encode(apiPosts)
        presenter.viewDidLoad()
        completionQueue.sync {
            // Just to wait for previous async calls
        }

        let indexPath = IndexPath(row: 0, section: 0)
        presenter.didSelectPostAtIndexPath(indexPath)

        switch navigator.destination {

        case .postDetailsViewController(let post)?:
            XCTAssertEqual(post, apiPosts[indexPath.row])
        default:
            XCTFail()
        }
    }

}

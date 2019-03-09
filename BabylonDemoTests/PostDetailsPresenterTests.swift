//
//  PostDetailsPresenterTests.swift
//  BabylonDemoTests
//
//  Created by Hesham Mohamed on 3/9/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import XCTest
import RealmSwift
@testable import BabylonDemo

fileprivate class URLSessionMock: URLSessionProtocol {
//    var authorParam: (data: Data?, userId: Int)!
//    var commentsParam: (data: Data?, postId: Int)!

    var data: [String: Data] = [:]
    var response: [String: URLResponse] = [:]
    var error: [String: Error] = [:]

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSessionDataTaskMock()

        task.action = {
            completionHandler(self.data[request.url!.absoluteString], self.response[request.url!.absoluteString], self.error[request.url!.absoluteString])
        }
        return task
    }
}

class PostDetailsPresenterTests: XCTestCase {
    private var presenter: PostDetailsPresenter!
    private var view: PostDetailsViewMock!
    private var postsProvider: PostsProviderProtocol!
    private var navigator: MockAppNavigator!
    private let post = Post(title: "Alb1", id: 1, body: "body1", userId: 2)
    private let apiComments = [Comment(id: 3, postId: 1, name: "comment3", email: "comment3@email.com", body: "body3"),Comment(id: 4, postId: 1, name: "comment4", email: "comment4@email.com", body: "body4")]

    private let cachedComments = [Comment(id: 1, postId: 1, name: "comment1", email: "comment1@email.com", body: "body1"),Comment(id: 2, postId: 1, name: "comment2", email: "comment2@email.com", body: "body2")]

    private let apiAuthor = [Author(id: 1, name: "name2", username: "username2", email: "Author2@email.com", address:
        Address(street: "street2", suite: "suite2", city: "city2", zipcode: "zipcode2", geo: Geo(lat: "123456", lng: "123456")))]

    private let cachedAuthor = [Author(id: 2, name: "name2", username: "username2", email: "Author1@email.com", address:
        Address(street: "street1", suite: "suite1", city: "city1", zipcode: "zipcode1", geo: Geo(lat: "123456", lng: "123456")))]

    private var baseUrl: String {
        return PostsAPI.getAuthor(userId: post.userId).baseURL.absoluteString
    }

    private var getAuthorUrlString: String {
        return baseUrl + PostsAPI.getAuthor(userId: post.userId).path
    }

    private var getCommentsUrlString: String{
        return baseUrl + PostsAPI.getComments(postId: post.id).path
    }

    private var dispatchGroup = DispatchGroup()
    private let completionQueue = DispatchQueue(label: "CompletionQueues")
    private var urlSessionMock: URLSessionMock!
    private var httpService: HttpService<PostsAPI>!
    private var cache: RealmCache!
    // private let notificationCenter: NotificationCenter

    override func setUp() {
        view = PostDetailsViewMock()
        urlSessionMock = URLSessionMock()
        httpService = HttpService<PostsAPI>(session: urlSessionMock)
        cache = RealmCache(realmFactory: { try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm")) } )
        postsProvider = PostsProvider(completionQueue: completionQueue, cache: cache, api: httpService)
        navigator = MockAppNavigator()
        presenter = PostDetailsPresenter(post: post, view: view, postsProvider: postsProvider, dispatchGroup: dispatchGroup, completionQueue: completionQueue)
    }

    override func tearDown() {
        presenter = nil
        view = nil
        postsProvider = nil
        navigator = nil
    }

    func testViewDidLoadSuccess() {
        urlSessionMock.data[getAuthorUrlString] = try! JSONEncoder().encode(apiAuthor)
        urlSessionMock.data[getCommentsUrlString] = try! JSONEncoder().encode(apiComments)

        presenter.viewDidLoad()

        dispatchGroup.wait()

        completionQueue.sync {}

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPostDetails)
        XCTAssertFalse(view.didShowError)
        XCTAssertEqual(apiAuthor[0], presenter.author)
        XCTAssertEqual(apiComments, presenter.comments)

    }

    func testReconnectInternet() {
        // set cache data
        cache.addAuthor(author: cachedAuthor[0])
        cache.addComments(comments: cachedComments)
        // set error type to network error
        let error = NSError(domain: "", code: 0, userInfo: [NSUnderlyingErrorKey: NSError(domain: kCFErrorDomainCFNetwork as String, code: 0, userInfo: nil)])

        urlSessionMock.error[getAuthorUrlString] = error
        urlSessionMock.error[getCommentsUrlString] = error

        presenter.viewDidLoad()

        dispatchGroup.wait()

        completionQueue.sync {}

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPostDetails) // it's executing only when there data in cache
        XCTAssertTrue(view.didShowError)

        // simulte reconneting internet
        let internetReconnectExpectation = expectation(description: "Internet reconnects")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // prepare data after internet becoming active
            self.urlSessionMock.data[self.getAuthorUrlString] = try! JSONEncoder().encode(self.apiAuthor)
            self.urlSessionMock.data[self.getCommentsUrlString] = try! JSONEncoder().encode(self.apiComments)
            self.view.didShowError = false
            NotificationCenter.default.post(name: .InternetStatus, object: nil, userInfo: [InternetConnection.Keys.InternetStatus: true])
            internetReconnectExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (_) in

        }

        // data is loaded from api successfully after reconnecting the internet
        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPostDetails)
        XCTAssertFalse(view.didShowError)
        XCTAssertEqual(apiAuthor[0], presenter.author!)
        XCTAssertEqual(apiComments, presenter.comments)
    }

    func testViewDidLoadFailureWithCachedData() {
        cache.addAuthor(author: cachedAuthor[0])
        cache.addComments(comments: cachedComments)

        let error = NSError(domain: "", code: 0, userInfo: [NSUnderlyingErrorKey: NSError(domain: kCFErrorDomainCFNetwork as String, code: 0, userInfo: nil)])

        urlSessionMock.error[getAuthorUrlString] = error
        urlSessionMock.error[getCommentsUrlString] = error

        presenter.viewDidLoad()

        dispatchGroup.wait()

        completionQueue.sync {
            // Just to wait for dispatchgroup notify block
        }

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPostDetails) // it's executing only when there data in cache
        XCTAssertTrue(view.didShowError)
    }

    func testViewDidLoadFailureWithNoCachedData() {
        let error = NSError(domain: "", code: 0, userInfo: [NSUnderlyingErrorKey: NSError(domain: kCFErrorDomainCFNetwork as String, code: 0, userInfo: nil)])

        urlSessionMock.error[getAuthorUrlString] = error
        urlSessionMock.error[getCommentsUrlString] = error

        presenter.viewDidLoad()

        dispatchGroup.wait()

        completionQueue.sync {
            // Just to wait for previous async calls
        }

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertFalse(view.didShowPostDetails) // There is no data in cache to show
        XCTAssertTrue(view.didShowError)
    }
}

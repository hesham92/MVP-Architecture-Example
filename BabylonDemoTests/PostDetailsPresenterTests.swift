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

class PostDetailsPresenterTests: XCTestCase {
    private var view: PostDetailsViewMock!
    private var presenter: PostDetailsPresenter!
    private var navigator: MockAppNavigator!
    private var postsProvider: PostsProviderProtocol!
    private var dispatchGroup: DispatchGroup!
    private var completionQueue: DispatchQueue!
    private var httpService: HttpService<PostsAPI>!
    private var urlSessionMock: URLSessionMock!
    private var cache: RealmCache!
    private var post: Post!
    private var apiComments: [Comment]!
    private var cachedComments: [Comment]!
    private var apiAuthor: [Author]!
    private var cachedAuthor: [Author]!

    private var baseUrl: String {
        return PostsAPI.getAuthor(userId: post.userId).baseURL.absoluteString
    }
    private var getAuthorUrlString: String {
        return baseUrl + PostsAPI.getAuthor(userId: post.userId).path
    }
    private var getCommentsUrlString: String{
        return baseUrl + PostsAPI.getComments(postId: post.id).path
    }

    override func setUp() {
        view = PostDetailsViewMock()
        navigator = MockAppNavigator()
        dispatchGroup = DispatchGroup()
        completionQueue = DispatchQueue(label: "CompletionQueues")
        urlSessionMock = URLSessionMock()
        httpService = HttpService<PostsAPI>(session: urlSessionMock)
        cache = RealmCache(realmFactory: { try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm")) } )
        postsProvider = PostsProvider(completionQueue: completionQueue, cache: cache, api: httpService)
        post = Post(title: "Alb1", id: 1, body: "body1", userId: 2)
        presenter = PostDetailsPresenter(post: post, view: view, postsProvider: postsProvider, dispatchGroup: dispatchGroup, completionQueue: completionQueue)

        apiComments = [Comment(id: 3, postId: 1, name: "comment3", email: "comment3@email.com", body: "body3"),Comment(id: 4, postId: 1, name: "comment4", email: "comment4@email.com", body: "body4")]
        cachedComments = [Comment(id: 1, postId: 1, name: "comment1", email: "comment1@email.com", body: "body1"),Comment(id: 2, postId: 1, name: "comment2", email: "comment2@email.com", body: "body2")]
        apiAuthor = [Author(id: 1, name: "name2", username: "username2",email: "Author2@email.com", address: Address(street: "street2", suite: "suite2", city: "city2", zipcode: "zipcode2", geo: Geo(lat: "123456", lng: "123456")))]
        cachedAuthor = [Author(id: 2, name: "name2", username: "username2", email: "Author1@email.com", address:
            Address(street: "street1", suite: "suite1", city: "city1", zipcode: "zipcode1", geo: Geo(lat: "123456", lng: "123456")))]

    }

    override func tearDown() {
        presenter = nil
        view = nil
        postsProvider = nil
        navigator = nil
        dispatchGroup = nil
        completionQueue = nil
        urlSessionMock = nil
        httpService = nil
        cache = nil
        post = nil
        apiComments = nil
        cachedComments = nil
        apiAuthor = nil
        cachedAuthor = nil
    }

    func testViewDidLoadSuccess() {
        // load API data
        urlSessionMock.data[getAuthorUrlString] = try! JSONEncoder().encode(apiAuthor)
        urlSessionMock.data[getCommentsUrlString] = try! JSONEncoder().encode(apiComments)

        presenter.viewDidLoad()

        // waiting
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
        // load cached data
        cache.addAuthor(author: cachedAuthor[0])
        cache.addComments(comments: cachedComments)

        //create network error
        let error = NSError(domain: "", code: 0, userInfo: [NSUnderlyingErrorKey: NSError(domain: kCFErrorDomainCFNetwork as String, code: 0, userInfo: nil)])

        urlSessionMock.error[getAuthorUrlString] = error
        urlSessionMock.error[getCommentsUrlString] = error

        presenter.viewDidLoad()

        // waiting
        dispatchGroup.wait()
        completionQueue.sync {}

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPostDetails) // it's executing only when there data in cache
        XCTAssertTrue(view.didShowError)

        // simulate reconneting internet
        let internetReconnectExpectation = expectation(description: "Internet reconnects")

        // waiting
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

            // prepare data after internet becoming active
            self.urlSessionMock.data[self.getAuthorUrlString] = try! JSONEncoder().encode(self.apiAuthor)
            self.urlSessionMock.data[self.getCommentsUrlString] = try! JSONEncoder().encode(self.apiComments)

            self.view.didShowError = false

            NotificationCenter.default.post(name: .InternetStatus, object: nil, userInfo: [InternetConnection.Keys.InternetStatus: true])

            internetReconnectExpectation.fulfill()
        }

        waitForExpectations(timeout: 10) { (_) in}

        // data is loaded from api successfully after reconnecting the internet
        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPostDetails)
        XCTAssertFalse(view.didShowError)
        XCTAssertEqual(apiAuthor[0], presenter.author!)
        XCTAssertEqual(apiComments, presenter.comments)
    }

    func testViewDidLoadFailureWithCachedData() {
        // load cached data
        cache.addAuthor(author: cachedAuthor[0])
        cache.addComments(comments: cachedComments)

        //create network error
        let error = NSError(domain: "", code: 0, userInfo: [NSUnderlyingErrorKey: NSError(domain: kCFErrorDomainCFNetwork as String, code: 0, userInfo: nil)])

        urlSessionMock.error[getAuthorUrlString] = error
        urlSessionMock.error[getCommentsUrlString] = error

        presenter.viewDidLoad()

        // waiting
        dispatchGroup.wait()
        completionQueue.sync {}

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertTrue(view.didShowPostDetails) // it's executing only when there data in cache
        XCTAssertTrue(view.didShowError)
    }

    func testViewDidLoadFailureWithNoCachedData() {
        //create network error
        let error = NSError(domain: "", code: 0, userInfo: [NSUnderlyingErrorKey: NSError(domain: kCFErrorDomainCFNetwork as String, code: 0, userInfo: nil)])

        urlSessionMock.error[getAuthorUrlString] = error
        urlSessionMock.error[getCommentsUrlString] = error

        presenter.viewDidLoad()

        // waiting
        dispatchGroup.wait() 
        completionQueue.sync {}

        XCTAssertTrue(view.didShowLoading)
        XCTAssertTrue(view.didHideLoading)
        XCTAssertFalse(view.didShowPostDetails) // There is no data in cache to show
        XCTAssertTrue(view.didShowError)
    }
}

fileprivate class URLSessionMock: URLSessionProtocol {
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

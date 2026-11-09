//
//  MockDataSource.swift
//  PostsAppTests
//
//  Created by Jan on 02/11/26.
//

import Foundation
@testable import PostsApp

enum MockData {
    static let samplePostResponse: PostResponse = [
        PostItemResponse(
            userId: 1,
            id: 1,
            title: "Swift Concurrency Guide",
            body: "Learn async/await and actors in Swift."
        ),
        PostItemResponse(
            userId: 1,
            id: 2,
            title: "Unit Testing with Mocks",
            body: "Testing view models using MockDataSource."
        ),
        PostItemResponse(
            userId: 2,
            id: 3,
            title: "SwiftUI NavigationStack",
            body: "Building modern navigation in iOS."
        )
    ]
    
    static let samplePosts: [Post] = PostMapper.responseToModel(
        response: samplePostResponse
    )
    
    static let sampleUsersResponse: UsersResponse = [
        UsersResponseElement(
            id: 1,
            name: "Leanne Graham",
            username: "Bret",
            email: "Sincere@april.biz",
            address: Address(
                street: "Kulas Light",
                suite: "Apt. 556",
                city: "Gwenborough",
                zipcode: "92998-3874",
                geo: Geo(lat: "-37.3159", lng: "81.1496")
            ),
            phone: "1-770-736-8031 x56442",
            website: "hildegard.org",
            company: Company(
                name: "Romaguera-Crona",
                catchPhrase: "Multi-layered client-server neural-net",
                bs: "harness real-time e-markets"
            )
        ),
        UsersResponseElement(
            id: 2,
            name: "Ervin Howell",
            username: "Antonette",
            email: "Shanna@melissa.tv",
            address: Address(
                street: "Victor Plains",
                suite: "Suite 879",
                city: "Wisokyburgh",
                zipcode: "90566-7771",
                geo: Geo(lat: "-43.9509", lng: "-34.4618")
            ),
            phone: "010-692-6593 x09125",
            website: "anastasia.net",
            company: Company(
                name: "Deckow-Crist",
                catchPhrase: "Proactive didactic contingency",
                bs: "synergize scalable supply-chains"
            )
        )
    ]
    
    static let sampleUsers: [User] = UserMapper.responseToModel(
        response: sampleUsersResponse
    )
}

final class MockDataSource: DataSourceProtocol, @unchecked Sendable {
    var postsResponse: PostResponse
    var usersResponse: UsersResponse
    var error: Error?
    var rawData: Data?
    
    private(set) var fetchCallCount: Int = 0
    private(set) var lastURL: String?
    private(set) var lastHTTPMethod: HTTPMethod?
    private(set) var lastHeaders: [String: String]?
    private(set) var lastQuery: [String: String]?
    private(set) var lastBody: Data?
    
    init(
        postsResponse: PostResponse = MockData.samplePostResponse,
        usersResponse: UsersResponse = MockData.sampleUsersResponse,
        error: Error? = nil,
        rawData: Data? = nil
    ) {
        self.postsResponse = postsResponse
        self.usersResponse = usersResponse
        self.error = error
        self.rawData = rawData
    }
    
    func fetch<T: Decodable & Sendable>(
        url: String,
        httpMethod: HTTPMethod,
        headers: [String: String]? = nil,
        query: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        fetchCallCount += 1
        lastURL = url
        lastHTTPMethod = httpMethod
        lastHeaders = headers
        lastQuery = query
        lastBody = body
        
        if let error {
            throw error
        }
        
        if let rawData {
            return try JSONDecoder().decode(T.self, from: rawData)
        }
        
        let data: Data
        if T.self == PostResponse.self {
            var filteredPosts = postsResponse
            if let userIdString = query?["userId"], let userId = Int(userIdString) {
                filteredPosts = filteredPosts.filter { $0.userId == userId }
            }
            data = try JSONEncoder().encode(filteredPosts)
        } else if T.self == UsersResponse.self {
            data = try JSONEncoder().encode(usersResponse)
        } else {
            throw RemoteDataSourceError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

final class MockPostServiceInjection: PostServiceInjection {
    private let dataSource: DataSourceProtocol
    
    init(dataSource: DataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func makePostService() -> PostServing {
        return PostService(dataSource: dataSource)
    }
}

final class MockUserServiceInjection: UserServiceInjection {
    private let dataSource: DataSourceProtocol
    
    init(dataSource: DataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func makeUserService() -> any UserService {
        return UserServiceImpl(dataSource: dataSource)
    }
}

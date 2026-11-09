//
//  UserService.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

import Foundation

protocol UserService: Sendable {
    func fetchListUser() async throws -> [User]
}

struct UserServiceImpl: UserService {
    
    private let dataSource: any DataSourceProtocol
    
    init(dataSource: any DataSourceProtocol = RemoteDataSource.shared) {
        self.dataSource = dataSource
    }
    
    func fetchListUser() async throws -> [User] {
        let response: UsersResponse = try await dataSource
            .fetch(
                url: "https://jsonplaceholder.typicode.com/users",
                httpMethod: .get,
                headers: nil,
                query: nil,
                body: nil
            )
        return UserMapper.responseToModel(response: response)
    }
}

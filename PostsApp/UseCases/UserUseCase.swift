//
//  UserUseCase.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

import Foundation

protocol UserUseCase: Sendable {
    func fetchListUsers() async throws -> [User]
}

struct UserUseCaseImpl {
    let service: UserService
    init(service: UserService) {
        self.service = service
    }
}

extension UserUseCaseImpl: UserUseCase {
    func fetchListUsers() async throws -> [User] {
        return try await service.fetchListUser()
    }
}

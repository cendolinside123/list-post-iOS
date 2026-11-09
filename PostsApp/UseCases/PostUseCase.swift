//
//  PostUseCase.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

import Foundation

protocol PostUseCase: Sendable {
    func fetchPosts(
        userId: Int?
    ) async throws -> [Post]
}

struct PostUseCaseImpl {
    private let postService: PostServing
    
    init(postService: PostServing) {
        self.postService = postService
    }
}

extension PostUseCaseImpl: PostUseCase {
    func fetchPosts(
        userId: Int?
    ) async throws -> [Post] {
        let query = PostQuery(
            userId: userId
        )
        return try await postService.fetchPosts(query: query)
    }
}

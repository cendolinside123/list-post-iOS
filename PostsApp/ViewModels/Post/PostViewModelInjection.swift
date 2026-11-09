//
//  PostViewModelInjection.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//


protocol PostServiceInjection: Sendable {
    func makePostService() -> PostServing
}

final class PostServiceInjectionImpl: PostServiceInjection {
    func makePostService() -> PostServing {
        return PostService(
            dataSource: RemoteDataSource.shared
        )
    }
}

@MainActor
protocol PostViewModelInjection: Sendable {
    func makePostViewModel() -> PostListViewModel
}

final class PostViewModelInjectionImpl: PostViewModelInjection {
    
    static let shared = PostViewModelInjectionImpl()
    
    private let service: PostServiceInjection
    
    init(
        service: PostServiceInjection = PostServiceInjectionImpl()
    ) {
        self.service = service
    }
    
    func makePostViewModel() -> PostListViewModel {
        
        let useCase = PostUseCaseImpl(postService: service.makePostService())
        
        return .init(
            useCase: useCase
        )
    }
}

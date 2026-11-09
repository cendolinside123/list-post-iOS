//
//  ListUserViewModelInjection.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

protocol UserServiceInjection: Sendable {
    func makeUserService() -> UserService
}

final class UserServiceInjectionImpl: UserServiceInjection {
    func makeUserService() -> any UserService {
        return UserServiceImpl(
            dataSource: RemoteDataSource.shared
        )
    }
}

@MainActor
protocol ListUserViewModelInjection: Sendable {
    func makeListUserViewModel() -> ListUserViewModel
}

final class ListUserViewModelInjectionImpl: ListUserViewModelInjection {
    
    static let shared = ListUserViewModelInjectionImpl()
    
    private let service: UserServiceInjection
    
    init(
        service: UserServiceInjection = UserServiceInjectionImpl()
    ) {
        self.service = service
    }
    
    func makeListUserViewModel() -> ListUserViewModel {
        let useCase = UserUseCaseImpl(
            service: service.makeUserService()
        )
        return .init(useCase: useCase)
    }
}

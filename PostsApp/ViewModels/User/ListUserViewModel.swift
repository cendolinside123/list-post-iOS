//
//  ListUserViewModel.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

import Foundation

@MainActor
protocol ListUserViewModelProtocol {
    var user: [User] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func loadUsers() async
}

final class ListUserViewModel: ObservableObject {
    @Published private(set) var user: [User] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let useCase: UserUseCase
    
    init(useCase: UserUseCase) {
        self.useCase = useCase
    }
    
}

extension ListUserViewModel: ListUserViewModelProtocol {
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        
        do {
            self.user = try await useCase.fetchListUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

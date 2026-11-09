//
//  ListUserViewModelTests.swift
//  PostsAppTests
//
//  Created by Jan on 02/11/26.
//

import XCTest
@testable import PostsApp

@MainActor
final class ListUserViewModelTests: XCTestCase {

    func testSuccessfulLoadUsersShowsUsers() async {
        let mockDataSource = MockDataSource(
            usersResponse: MockData.sampleUsersResponse
        )
        let serviceInjection = MockUserServiceInjection(dataSource: mockDataSource)
        let injection = ListUserViewModelInjectionImpl(service: serviceInjection)
        let vm = injection.makeListUserViewModel()
        
        await vm.loadUsers()
        
        XCTAssertEqual(vm.user, MockData.sampleUsers)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(mockDataSource.fetchCallCount, 1)
        XCTAssertEqual(mockDataSource.lastURL, "https://jsonplaceholder.typicode.com/users")
        XCTAssertEqual(mockDataSource.lastHTTPMethod, .get)
        XCTAssertNil(mockDataSource.lastQuery)
    }

    func testLoadUsersFailureSetsErrorMessage() async {
        let mockDataSource = MockDataSource(
            error: RemoteDataSourceError.httpStatus(404)
        )
        let serviceInjection = MockUserServiceInjection(dataSource: mockDataSource)
        let injection = ListUserViewModelInjectionImpl(service: serviceInjection)
        let vm = injection.makeListUserViewModel()
        
        await vm.loadUsers()
        
        XCTAssertTrue(vm.user.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(
            vm.errorMessage,
            RemoteDataSourceError.httpStatus(404).localizedDescription
        )
    }

    func testLoadUsersFailurePreservesExistingUsers() async {
        let mockDataSource = MockDataSource(
            usersResponse: MockData.sampleUsersResponse
        )
        let serviceInjection = MockUserServiceInjection(dataSource: mockDataSource)
        let injection = ListUserViewModelInjectionImpl(service: serviceInjection)
        let vm = injection.makeListUserViewModel()
        
        await vm.loadUsers()
        XCTAssertEqual(vm.user, MockData.sampleUsers)
        XCTAssertNil(vm.errorMessage)
        
        mockDataSource.error = RemoteDataSourceError.invalidResponse
        await vm.loadUsers()
        
        XCTAssertEqual(vm.user, MockData.sampleUsers)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(
            vm.errorMessage,
            RemoteDataSourceError.invalidResponse.localizedDescription
        )
        
        mockDataSource.error = nil
        await vm.loadUsers()
        
        XCTAssertEqual(vm.user, MockData.sampleUsers)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }
}

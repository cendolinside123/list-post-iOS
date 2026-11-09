import XCTest
@testable import PostsApp

@MainActor
final class PostListViewModelTests: XCTestCase {

    func testSuccessfulLoadShowsPosts() async {
        let mockDataSource = MockDataSource(
            postsResponse: MockData.samplePostResponse
        )
        let serviceInjection = MockPostServiceInjection(dataSource: mockDataSource)
        let injection = PostViewModelInjectionImpl(service: serviceInjection)
        let vm = injection.makePostViewModel()
        
        await vm.loadPosts()
        
        XCTAssertEqual(vm.posts, MockData.samplePosts)
        XCTAssertEqual(vm.visiblePosts, MockData.samplePosts)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(mockDataSource.fetchCallCount, 1)
        XCTAssertEqual(mockDataSource.lastURL, "https://jsonplaceholder.typicode.com/posts")
        XCTAssertEqual(mockDataSource.lastHTTPMethod, .get)
        XCTAssertNil(mockDataSource.lastQuery)
    }

    func testLoadPostsFailureSetsErrorMessage() async {
        let mockDataSource = MockDataSource(
            error: RemoteDataSourceError.httpStatus(500)
        )
        let serviceInjection = MockPostServiceInjection(dataSource: mockDataSource)
        let injection = PostViewModelInjectionImpl(service: serviceInjection)
        let vm = injection.makePostViewModel()
        
        await vm.loadPosts()
        
        XCTAssertTrue(vm.posts.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(
            vm.errorMessage,
            RemoteDataSourceError.httpStatus(500).localizedDescription
        )
    }

    func testLoadPostsFailurePreservesExistingPosts() async {
        let mockDataSource = MockDataSource(
            postsResponse: MockData.samplePostResponse
        )
        let serviceInjection = MockPostServiceInjection(dataSource: mockDataSource)
        let injection = PostViewModelInjectionImpl(service: serviceInjection)
        let vm = injection.makePostViewModel()
        
        await vm.loadPosts()
        XCTAssertEqual(vm.posts, MockData.samplePosts)
        XCTAssertNil(vm.errorMessage)
        
        mockDataSource.error = RemoteDataSourceError.invalidResponse
        await vm.loadPosts()
        
        XCTAssertEqual(vm.posts, MockData.samplePosts)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(
            vm.errorMessage,
            RemoteDataSourceError.invalidResponse.localizedDescription
        )
        
        mockDataSource.error = nil
        await vm.loadPosts()
        
        XCTAssertEqual(vm.posts, MockData.samplePosts)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func testToastManagerShowsAndDismissesErrorToast() {
        let manager = ToastManager()
        let errorMessage = RemoteDataSourceError.invalidResponse.localizedDescription
        
        XCTAssertNil(manager.currentToast)
        
        manager.show(style: .error, message: errorMessage)
        XCTAssertEqual(manager.currentToast?.style, .error)
        XCTAssertEqual(manager.currentToast?.message, errorMessage)
        
        manager.dismissCurrentToast()
        XCTAssertNil(manager.currentToast)
    }

    func testFilterPostsByUserId() async {
        let mockDataSource = MockDataSource(
            postsResponse: MockData.samplePostResponse
        )
        let serviceInjection = MockPostServiceInjection(dataSource: mockDataSource)
        let injection = PostViewModelInjectionImpl(service: serviceInjection)
        let vm = injection.makePostViewModel()
        vm.userId = 1
        
        await vm.loadPosts()
        
        let expectedPosts = MockData.samplePosts.filter { $0.userId == 1 }
        XCTAssertEqual(vm.posts, expectedPosts)
        XCTAssertEqual(mockDataSource.lastQuery, ["userId": "1"])
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func testSearchTextFiltersVisiblePostsCaseInsensitively() async {
        let mockDataSource = MockDataSource(
            postsResponse: MockData.samplePostResponse
        )
        let serviceInjection = MockPostServiceInjection(dataSource: mockDataSource)
        let injection = PostViewModelInjectionImpl(service: serviceInjection)
        let vm = injection.makePostViewModel()
        
        await vm.loadPosts()
        
        vm.searchText = "swift"
        XCTAssertEqual(vm.visiblePosts.count, 2)
        XCTAssertEqual(vm.visiblePosts.map(\.id), [1, 3])
        
        vm.searchText = "UNIT TESTING"
        XCTAssertEqual(vm.visiblePosts.count, 1)
        XCTAssertEqual(vm.visiblePosts.first?.id, 2)
        
        vm.searchText = "   "
        XCTAssertEqual(vm.visiblePosts, MockData.samplePosts)
        
        vm.searchText = "nonexistent keyword"
        XCTAssertTrue(vm.visiblePosts.isEmpty)
        XCTAssertEqual(vm.posts.count, 3)
    }
}

import Foundation

protocol PostServing: Sendable {
    func fetchPosts(
        query: PostQuery
    ) async throws -> [Post]
}

struct PostService: PostServing {
    private let dataSource: any DataSourceProtocol
    
    init(dataSource: any DataSourceProtocol = RemoteDataSource.shared) {
        self.dataSource = dataSource
    }

    func fetchPosts(
        query: PostQuery
    ) async throws -> [Post] {
        let url = "https://jsonplaceholder.typicode.com/posts"
        
        let responseResult: PostResponse = try await dataSource
            .fetch(
                url: url,
                httpMethod: .get,
                headers: nil,
                query: query.toDictionary,
                body: nil
            )
        
        return PostMapper
            .responseToModel(
                response: responseResult
            )
    }
}

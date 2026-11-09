//
//  RemoteDataSource.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//
import Foundation

struct RemoteDataSource {
    
    static let shared = RemoteDataSource()
    
    private let session: URLSession = .shared
}

extension RemoteDataSource: DataSourceProtocol {
    func fetch<T>(
        url: String,
        httpMethod: HTTPMethod,
        headers: [String : String]? = nil,
        query: [String : String]? = nil,
        body: Data? = nil
    ) async throws -> T where T : Decodable, T : Sendable {
            
            var urlBuilder = URLComponents(string: url)
            
            // setup url query
            urlBuilder?.queryItems = query?.map({
                URLQueryItem(name: $0.key, value: $0.value)
            })
            
            guard let url = urlBuilder?.url else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod.rawValue
            
            request.httpBody = body
            
            // setup headers
            if let headers {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            
            let (data, response) = try await session.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                throw RemoteDataSourceError.invalidResponse
            }
            guard (200...299).contains(http.statusCode) else {
                throw RemoteDataSourceError.httpStatus(http.statusCode)
            }
            
            let responseResult = try JSONDecoder()
                .decode(
                    T.self,
                    from: data
                )
            return responseResult
    }
}

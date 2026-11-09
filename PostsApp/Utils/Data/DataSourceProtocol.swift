//
//  DataSourceProtocol.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//
import Foundation

protocol DataSourceProtocol: Sendable {
    func fetch<T: Decodable & Sendable>(
        url: String,
        httpMethod: HTTPMethod,
        headers: [String: String]?,
        query: [String: String]?,
        body: Data?
    ) async throws -> T
}

